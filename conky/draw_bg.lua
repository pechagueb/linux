require 'cairo'
-- Intenta cargar cairo_xlib de forma segura
local ok, _ = pcall(require, 'cairo_xlib')

function conky_draw_bg()
    -- Verificamos que la ventana de Conky exista para evitar errores
    if conky_window == nil then return end
    
    local w = conky_window.width
    local h = conky_window.height
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, w, h)
    local cr = cairo_create(cs)

    -- Configuración del borde
    local corner_r = 10       
    local bg_color = 0x0A192F -- Azul marino oscuro
    local bg_alpha = 0.8      -- Transparencia (80%)
    local border_color = 0x008744 -- Verde
    local border_width = 2    
        
    -- Dibujar fondo redondeado
    cairo_new_sub_path(cr)
    cairo_arc(cr, w - corner_r, corner_r, corner_r, -math.pi/2, 0)
    cairo_arc(cr, w - corner_r, h - corner_r, corner_r, 0, math.pi/2)
    cairo_arc(cr, corner_r, h - corner_r, corner_r, math.pi/2, math.pi)
    cairo_arc(cr, corner_r, corner_r, corner_r, math.pi, 3*math.pi/2)
    cairo_close_path(cr)

    -- Rellenar fondo
    cairo_set_source_rgba(cr, ((bg_color >> 16) & 0xFF)/255, ((bg_color >> 8) & 0xFF)/255, (bg_color & 0xFF)/255, bg_alpha)
    cairo_fill_preserve(cr)

    -- Dibujar borde
    cairo_set_source_rgba(cr, ((border_color >> 16) & 0xFF)/255, ((border_color >> 8) & 0xFF)/255, (border_color & 0xFF)/255, 1.0)
    cairo_set_line_width(cr, border_width)
    cairo_stroke(cr)

    -- Limpiamos la memoria (muy importante para que no consuma RAM)
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end