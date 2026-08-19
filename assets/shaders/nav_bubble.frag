// nav_bubble.frag — integrated optical deformation for the bottom-nav pill.
//
// The pill is a single glass surface; this shader gives that SAME surface a
// gentle convex-lens behaviour in the area around the active item. There is
// no lens bubble, no rim, no visible boundary: the backdrop is magnified
// softly at the item centre, the displacement fades with a mask that reaches
// exactly zero (zero slope) well before the item edge, and outside the area
// the backdrop passes through untouched.
//
// Uniforms (12 floats, order fixed — see NavGlassBubble._paint):
//   u_resolution  vec2  — full-screen physical size in px
//   u_center      vec2  — effect centre in screen space (px, y-down)
//   u_bubble      vec4  — x: optical radius px, y: strength 0..1,
//                         z: stretchX, w: stretchY (liquid deformation)
//   u_optics      vec4  — x: highlight intensity (y..w unused)
//
// The backdrop is sampled through `u_texture_input` exactly like the lens's
// own shader (full-frame, physical px, GLES y-flip guard).

#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 u_resolution;
uniform vec2 u_center;
uniform vec4 u_bubble;
uniform vec4 u_optics;

uniform sampler2D u_texture_input;

out vec4 frag_color;

void main() {
  vec2 fragPx = FlutterFragCoord().xy;
  vec2 uv = fragPx / u_resolution;
#ifdef IMPELLER_TARGET_OPENGLES
#ifndef IMPELLER_OPENGLES_UNFLIPPED_DEPRECATED
  uv.y = 1.0 - uv.y;
#endif
#endif

  // Normalized distance from the effect centre, elliptical while the effect
  // is stretched by motion (u_bubble.z/w).
  vec2 toC = fragPx - u_center;
  vec2 stretch = max(vec2(u_bubble.z, u_bubble.w), vec2(0.0001));
  float nd = length(toC / (u_bubble.x * stretch));

  // Pure passthrough outside the optical area — no change at all.
  if (nd >= 1.0) {
    frag_color = texture(u_texture_input, uv);
    return;
  }

  float strength = clamp(u_bubble.y, 0.0, 1.0);

  // Very soft mask: (1 - nd²)³ is 1 at the centre, reaches exactly 0 with
  // zero slope at nd == 1, and the visible effect is concentrated well
  // inside — there is no circle edge to catch the eye, and nothing leaks
  // past the optical radius.
  float g = 1.0 - nd * nd;
  g = g * g * g;

  // Convex-lens sampling: pull samples INWARD toward the centre so the glass
  // surface magnifies — the backdrop is read slightly closer to the centre,
  // which is exactly how a real magnifying glass behaves.
  //
  // Refraction: adds a smooth radial surface deflection proportional to the
  // slope of the convex lens profile (derivative of g), fading cleanly to 0
  // at the mask boundary.
  float magnification = 0.08 * strength * g;
  float slope = 6.0 * nd * (1.0 - nd * nd) * (1.0 - nd * nd);
  float refraction = 0.015 * strength * slope;
  float sampleScale = 1.0 - (magnification + refraction);
  vec2 magnifiedPx = u_center + toC * sampleScale;

  vec2 sampleUV = clamp(magnifiedPx / u_resolution, vec2(0.001), vec2(0.999));
#ifdef IMPELLER_TARGET_OPENGLES
#ifndef IMPELLER_OPENGLES_UNFLIPPED_DEPRECATED
  sampleUV.y = 1.0 - sampleUV.y;
#endif
#endif

  vec4 sampled = texture(u_texture_input, sampleUV);
  vec3 color = sampled.rgb;

  // Very subtle sheen that follows the deformation: a gentle luminance lift
  // near the centre, shaped by the same soft mask — not a separate
  // highlight shape, so no bubble reads.
  float hl = exp(-dot(toC, toC) / (2.0 * u_bubble.x * u_bubble.x * 0.30));
  color += vec3(1.0) * hl * g * strength * u_optics.x;

  // Preserve the backdrop's alpha: if the backdrop isn't ready yet (first
  // frame), the lens stays transparent instead of painting opaque black.
  frag_color = vec4(color, sampled.a);
}