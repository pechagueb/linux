#Nombre: pong.py
#Autor: Patricio Echagüe Ballesteros (YAPA Design)
#WEB: https://pechagueb.odoo.com/
#Descripción: Primer videojuego de ping pong

#Instalación de librería pygame en linux:
#sudo apt install python3-pygame
import pygame

import random

# --- Constantes ---
# Colores
NEGRO = (0, 0, 0)
BLANCO = (255, 255, 255)

# Dimensiones de la pantalla
ANCHO_PANTALLA = 800
ALTO_PANTALLA = 600

# Dimensiones y velocidad de las paletas
ANCHO_PALETA = 15
ALTO_PALETA = 100
VELOCIDAD_PALETA = 7 # Píxeles por frame

# Dimensiones y velocidad de la pelota
RADIO_PELOTA = 10
VELOCIDAD_PELOTA_X_INICIAL = 5
VELOCIDAD_PELOTA_Y_INICIAL = 5

# --- Clases ---

class Paleta(pygame.sprite.Sprite):
    def __init__(self, color, x, y):
        super().__init__()
        self.image = pygame.Surface([ANCHO_PALETA, ALTO_PALETA])
        self.image.fill(color)
        self.rect = self.image.get_rect()
        self.rect.x = x
        self.rect.y = y
        self.velocidad_y = 0

    def mover_arriba(self):
        self.velocidad_y = -VELOCIDAD_PALETA

    def mover_abajo(self):
        self.velocidad_y = VELOCIDAD_PALETA

    def parar(self):
        self.velocidad_y = 0

    def update(self):
        self.rect.y += self.velocidad_y
        # Evitar que la paleta se salga de la pantalla
        if self.rect.y < 0:
            self.rect.y = 0
        if self.rect.y > ALTO_PANTALLA - ALTO_PALETA:
            self.rect.y = ALTO_PANTALLA - ALTO_PALETA

class Pelota(pygame.sprite.Sprite):
    def __init__(self, color):
        super().__init__()
        self.image = pygame.Surface([RADIO_PELOTA * 2, RADIO_PELOTA * 2])
        self.image.set_colorkey(NEGRO) # Para hacer el fondo del sprite transparente
        pygame.draw.circle(self.image, color, (RADIO_PELOTA, RADIO_PELOTA), RADIO_PELOTA)
        self.rect = self.image.get_rect()
        self.velocidad_x = random.choice([-VELOCIDAD_PELOTA_X_INICIAL, VELOCIDAD_PELOTA_X_INICIAL])
        self.velocidad_y = random.choice([-VELOCIDAD_PELOTA_Y_INICIAL, VELOCIDAD_PELOTA_Y_INICIAL])
        self.resetear()

    def update(self):
        self.rect.x += self.velocidad_x
        self.rect.y += self.velocidad_y

        # Rebotar en los bordes superior e inferior
        if self.rect.y > ALTO_PANTALLA - RADIO_PELOTA * 2 or self.rect.y < 0:
            self.velocidad_y *= -1

    def resetear(self):
        self.rect.x = ANCHO_PANTALLA // 2 - RADIO_PELOTA
        self.rect.y = ALTO_PANTALLA // 2 - RADIO_PELOTA
        # Dirección aleatoria después de un punto
        self.velocidad_x = random.choice([-VELOCIDAD_PELOTA_X_INICIAL, VELOCIDAD_PELOTA_X_INICIAL])
        self.velocidad_y = random.choice([-VELOCIDAD_PELOTA_Y_INICIAL, VELOCIDAD_PELOTA_Y_INICIAL])
        # Pequeña pausa
        pygame.time.wait(500)


# --- Inicialización de Pygame ---
pygame.init()

# Configuración de la pantalla
pantalla = pygame.display.set_mode((ANCHO_PANTALLA, ALTO_PANTALLA))
pygame.display.set_caption("Pong Clásico")

# Reloj para controlar los FPS
reloj = pygame.time.Clock()

# Crear objetos del juego
paleta_izquierda = Paleta(BLANCO, 50, ALTO_PANTALLA // 2 - ALTO_PALETA // 2)
paleta_derecha = Paleta(BLANCO, ANCHO_PANTALLA - 50 - ANCHO_PALETA, ALTO_PANTALLA // 2 - ALTO_PALETA // 2)
pelota = Pelota(BLANCO)

# Grupo de sprites para facilitar las actualizaciones y el dibujado
todos_los_sprites = pygame.sprite.Group()
todos_los_sprites.add(paleta_izquierda, paleta_derecha, pelota)

# Puntuaciones
puntuacion_izquierda = 0
puntuacion_derecha = 0
fuente = pygame.font.Font(None, 74) # Fuente por defecto, tamaño 74

# --- Bucle principal del juego ---
jugando = True
while jugando:
    for evento in pygame.event.get():
        if evento.type == pygame.QUIT:
            jugando = False

        # Movimiento de paletas con pulsación de tecla
        if evento.type == pygame.KEYDOWN:
            # Paleta izquierda (W para arriba, S para abajo)
            if evento.key == pygame.K_w:
                paleta_izquierda.mover_arriba()
            if evento.key == pygame.K_s:
                paleta_izquierda.mover_abajo()
            # Paleta derecha (Flecha arriba para arriba, Flecha abajo para abajo)
            if evento.key == pygame.K_UP:
                paleta_derecha.mover_arriba()
            if evento.key == pygame.K_DOWN:
                paleta_derecha.mover_abajo()

        # Parar paletas cuando se suelta la tecla
        if evento.type == pygame.KEYUP:
            if evento.key == pygame.K_w or evento.key == pygame.K_s:
                paleta_izquierda.parar()
            if evento.key == pygame.K_UP or evento.key == pygame.K_DOWN:
                paleta_derecha.parar()

    # --- Lógica del juego ---
    todos_los_sprites.update() # Llama al método update() de cada sprite

    # Colisiones de la pelota con las paletas
    if pygame.sprite.collide_rect(pelota, paleta_izquierda) or \
       pygame.sprite.collide_rect(pelota, paleta_derecha):
        pelota.velocidad_x *= -1
        # Pequeño ajuste para evitar que la pelota se quede "pegada"
        if pelota.velocidad_x > 0: # Si se mueve a la derecha
             pelota.rect.x = max(pelota.rect.x, paleta_izquierda.rect.right if pygame.sprite.collide_rect(pelota, paleta_izquierda) else pelota.rect.x)
        else: # Si se mueve a la izquierda
             pelota.rect.x = min(pelota.rect.x, paleta_derecha.rect.left - pelota.rect.width if pygame.sprite.collide_rect(pelota, paleta_derecha) else pelota.rect.x)


    # Comprobar si alguien anota
    if pelota.rect.x >= ANCHO_PANTALLA - RADIO_PELOTA * 2 : # Pelota sale por la derecha
        puntuacion_izquierda += 1
        pelota.resetear()
    if pelota.rect.x < 0: # Pelota sale por la izquierda
        puntuacion_derecha += 1
        pelota.resetear()

    # --- Dibujar en pantalla ---
    pantalla.fill(NEGRO) # Fondo negro

    # Línea central (opcional, estética)
    pygame.draw.line(pantalla, BLANCO, [ANCHO_PANTALLA // 2, 0], [ANCHO_PANTALLA // 2, ALTO_PANTALLA], 5)

    todos_los_sprites.draw(pantalla) # Dibuja todos los sprites

    # Dibujar puntuaciones
    texto_izquierda = fuente.render(str(puntuacion_izquierda), True, BLANCO)
    pantalla.blit(texto_izquierda, (ANCHO_PANTALLA // 4, 10))

    texto_derecha = fuente.render(str(puntuacion_derecha), True, BLANCO)
    pantalla.blit(texto_derecha, (ANCHO_PANTALLA * 3 // 4 - texto_derecha.get_width(), 10))

    # Actualizar la pantalla
    pygame.display.flip()

    # Controlar FPS
    reloj.tick(60) # 60 frames por segundo

# --- Salir de Pygame ---
pygame.quit()
