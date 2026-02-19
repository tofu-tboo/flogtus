shader_type canvas_item;
render_mode unshaded;

uniform vec2  center_px = vec2(640.0, 360.0);
uniform float outer_r_px = 128.0;   // 안쪽 반경 a
uniform float thickness_px = 2.0;   // 두께(= b - a)
uniform bool  snap_pixels = true;   // 픽셀 정렬(가급적 켜두면 깜빡임 줄어듦)

void fragment() {
    vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 px = SCREEN_UV * screen_size;
    if (snap_pixels) px = floor(px) + 0.5;

    float d = distance(px, center_px);
    float inner_r_px = outer_r_px - max(thickness_px, 0.0);

    // 링 영역이 아니면 투명(뒤 배경이 보임)
    if (d < inner_r_px || d > outer_r_px) {
        discard;
    }

    // 링 영역만 색을 출력(스프라이트 텍스처는 쓰지 않음)
    COLOR = texture(TEXTURE, UV);
}