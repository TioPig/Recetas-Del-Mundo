import React from 'react';
import Container from '@mui/material/Container';
import Grid from '@mui/material/Grid';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import { Link as RouterLink } from 'react-router-dom';

export default function Footer(){
  return (
    <Box 
      component="footer" 
      sx={{ 
        background: 'linear-gradient(135deg, #4FACFE 0%, #00F2FE 100%)',
        color: '#fff', 
        py: { xs: 4, md: 6 }, 
        mt: 0,
        boxShadow: '0 -4px 20px rgba(79, 172, 254, 0.3)'
      }}
    >
      <Container maxWidth="lg">
        <Grid container spacing={4} justifyContent="center">
          {/* Logo y Descripción */}
          <Grid item xs={12} md={6}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, mb: 2, justifyContent: { xs: 'center', md: 'flex-start' } }}>
              <Box 
                component="img" 
                src="/img/cheems-waso.png" 
                alt="logo" 
                sx={{ 
                  height: 50, 
                  width: 'auto',
                  borderRadius: '50%',
                  border: '3px solid white',
                  boxShadow: '0 2px 8px rgba(0,0,0,0.2)'
                }} 
              />
              <Box>
                <Typography 
                  variant="h6" 
                  sx={{ 
                    fontFamily: 'Lato, sans-serif', 
                    fontWeight: 900,
                    fontSize: '1.4rem',
                    lineHeight: 1.2
                  }}
                >
                  Recetas del Mundo
                </Typography>
                <Typography 
                  variant="caption" 
                  sx={{ 
                    fontFamily: 'Open Sans, sans-serif',
                    opacity: 0.95
                  }}
                >
                  Sabores únicos de todo el mundo
                </Typography>
              </Box>
            </Box>
            <Typography 
              sx={{ 
                fontFamily: 'Open Sans, sans-serif', 
                fontWeight: 400,
                fontSize: '0.95rem',
                lineHeight: 1.7,
                opacity: 0.95,
                mb: 2,
                textAlign: { xs: 'center', md: 'left' }
              }}
            >
              Descubre las mejores recetas internacionales. Un sitio donde podrás encontrar la receta perfecta para esa ocasión especial.
            </Typography>
          </Grid>

          {/* Enlaces Rápidos */}
          <Grid item xs={12} md={4}>
            <Typography 
              variant="h6" 
              sx={{ 
                fontFamily: 'Lato, sans-serif', 
                fontWeight: 900,
                mb: 2,
                fontSize: '1.1rem',
                textAlign: { xs: 'center', md: 'left' }
              }}
            >
              Enlaces Rápidos
            </Typography>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1, alignItems: { xs: 'center', md: 'flex-start' } }}>
              <RouterLink 
                to="/" 
                style={{ 
                  textDecoration: 'none', 
                  color: 'white',
                  fontFamily: 'Open Sans, sans-serif',
                  opacity: 0.9,
                  transition: 'all 0.3s'
                }}
                onMouseEnter={(e) => { e.target.style.opacity = '1'; e.target.style.paddingLeft = '5px'; }}
                onMouseLeave={(e) => { e.target.style.opacity = '0.9'; e.target.style.paddingLeft = '0'; }}
              >
                Inicio
              </RouterLink>
              <RouterLink 
                to="/paises" 
                style={{ 
                  textDecoration: 'none', 
                  color: 'white',
                  fontFamily: 'Open Sans, sans-serif',
                  opacity: 0.9,
                  transition: 'all 0.3s'
                }}
                onMouseEnter={(e) => { e.target.style.opacity = '1'; e.target.style.paddingLeft = '5px'; }}
                onMouseLeave={(e) => { e.target.style.opacity = '0.9'; e.target.style.paddingLeft = '0'; }}
              >
                Países
              </RouterLink>
              <RouterLink 
                to="/categorias" 
                style={{ 
                  textDecoration: 'none', 
                  color: 'white',
                  fontFamily: 'Open Sans, sans-serif',
                  opacity: 0.9,
                  transition: 'all 0.3s'
                }}
                onMouseEnter={(e) => { e.target.style.opacity = '1'; e.target.style.paddingLeft = '5px'; }}
                onMouseLeave={(e) => { e.target.style.opacity = '0.9'; e.target.style.paddingLeft = '0'; }}
              >
                Categorías
              </RouterLink>
              <RouterLink 
                to="/nueva-receta" 
                style={{ 
                  textDecoration: 'none', 
                  color: 'white',
                  fontFamily: 'Open Sans, sans-serif',
                  opacity: 0.9,
                  transition: 'all 0.3s'
                }}
                onMouseEnter={(e) => { e.target.style.opacity = '1'; e.target.style.paddingLeft = '5px'; }}
                onMouseLeave={(e) => { e.target.style.opacity = '0.9'; e.target.style.paddingLeft = '0'; }}
              >
                Añadir Receta
              </RouterLink>
            </Box>
          </Grid>
        </Grid>

        {/* Copyright */}
        <Box 
          sx={{ 
            borderTop: '1px solid rgba(255,255,255,0.2)', 
            mt: 4, 
            pt: 3, 
            textAlign: 'center' 
          }}
        >
          <Typography 
            sx={{ 
              fontFamily: 'Open Sans, sans-serif',
              opacity: 0.9,
              fontSize: '0.9rem'
            }}
          >
            &copy; {new Date().getFullYear()} Recetas del Mundo. Todos los derechos reservados. | Powered by Spring Boot 3.1.0
          </Typography>
        </Box>
      </Container>
    </Box>
  );
}
