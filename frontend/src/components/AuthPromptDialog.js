import React from 'react';
import Dialog from '@mui/material/Dialog';
import DialogContent from '@mui/material/DialogContent';
import DialogActions from '@mui/material/DialogActions';
import Button from '@mui/material/Button';
import Typography from '@mui/material/Typography';
import Box from '@mui/material/Box';
import { useNavigate } from 'react-router-dom';

export default function AuthPromptDialog({ open, onClose }){
  const navigate = useNavigate();
  return (
    <Dialog 
      open={open} 
      onClose={onClose} 
      maxWidth="md" 
      fullWidth
      PaperProps={{
        sx: {
          borderRadius: 3,
          overflow: 'hidden',
          boxShadow: '0 8px 32px rgba(102, 126, 234, 0.2)'
        }
      }}
    >
      <DialogContent sx={{ p: 0, minHeight: 280 }}>
        <Box sx={{ display: 'flex', flexDirection: { xs: 'column', md: 'row' }, alignItems: 'stretch', gap: 0, height: '100%' }}>
          {/* Left column: content and buttons */}
          <Box 
            sx={{ 
              flex: 1, 
              p: { xs: 3, md: 4 }, 
              display: 'flex', 
              flexDirection: 'column', 
              justifyContent: 'space-between',
              background: 'linear-gradient(135deg, rgba(102, 126, 234, 0.05) 0%, rgba(118, 75, 162, 0.05) 100%)'
            }}
          >
            <Box>
              <Box 
                sx={{ 
                  display: 'inline-block',
                  background: 'linear-gradient(135deg, #667EEA 0%, #764BA2 100%)',
                  borderRadius: 2,
                  px: 2,
                  py: 0.5,
                  mb: 2
                }}
              >
                <Typography 
                  sx={{ 
                    color: '#FFFFFF', 
                    fontFamily: 'Lato, sans-serif', 
                    fontWeight: 800, 
                    fontSize: { xs: '1.1rem', md: '1.25rem' },
                    letterSpacing: 0.5
                  }}
                >
                  🍳 Únete al Mundo Culinario
                </Typography>
              </Box>
              <Typography 
                sx={{ 
                  color: '#4A5568', 
                  fontFamily: 'Open Sans, sans-serif',
                  fontSize: { xs: '0.95rem', md: '1rem' },
                  lineHeight: 1.6,
                  mb: 2
                }}
              >
                Para apoyar a <strong style={{ color: '#667EEA' }}>Recetas del Mundo y tus recetas favoritas</strong> debes iniciar sesión o crear una cuenta.
              </Typography>
              <Typography 
                variant="caption" 
                sx={{ 
                  color: '#718096',
                  fontFamily: 'Open Sans, sans-serif',
                  display: 'block',
                  fontStyle: 'italic'
                }}
              >
                ✨ Es rápido, gratis y te abre las puertas a miles de recetas
              </Typography>
            </Box>
            <Box sx={{ display: 'flex', gap: 2, alignItems: 'center', mt: 3, flexDirection: { xs: 'column', sm: 'row' } }}>
              <Button 
                onClick={()=>{ onClose(); navigate('/login'); }} 
                variant="outlined" 
                fullWidth
                sx={{ 
                  color: '#667EEA', 
                  borderColor: '#667EEA',
                  fontFamily: 'Lato, sans-serif',
                  fontWeight: 700,
                  py: 1.2,
                  fontSize: { xs: '0.95rem', md: '1rem' },
                  borderRadius: 2,
                  borderWidth: 2,
                  textTransform: 'none',
                  transition: 'all 0.3s ease',
                  '&:hover': { 
                    borderColor: '#764BA2',
                    backgroundColor: 'rgba(102, 126, 234, 0.08)',
                    transform: 'translateY(-2px)',
                    borderWidth: 2
                  }
                }}
              >
                Iniciar sesión
              </Button>
              <Button 
                onClick={()=>{ onClose(); navigate('/register'); }} 
                variant="contained" 
                fullWidth
                sx={{ 
                  background: 'linear-gradient(135deg, #F093FB 0%, #F5576C 100%)',
                  color: '#FFFFFF',
                  fontFamily: 'Lato, sans-serif',
                  fontWeight: 700,
                  py: 1.2,
                  fontSize: { xs: '0.95rem', md: '1rem' },
                  borderRadius: 2,
                  textTransform: 'none',
                  boxShadow: '0 4px 15px rgba(240, 147, 251, 0.4)',
                  transition: 'all 0.3s ease',
                  '&:hover': { 
                    transform: 'translateY(-2px)',
                    boxShadow: '0 6px 20px rgba(240, 147, 251, 0.6)'
                  }
                }}
              >
                Crear cuenta
              </Button>
            </Box>
          </Box>

          {/* Right column: image */}
          <Box 
            sx={{ 
              flex: 1, 
              display: { xs: 'none', md: 'flex' },
              alignItems: 'stretch', 
              justifyContent: 'center',
              position: 'relative',
              overflow: 'hidden'
            }}
          >
            <Box 
              component="img" 
              src="/img/chef.jpg" 
              alt="Chef" 
              sx={{ 
                width: '100%', 
                height: '100%', 
                objectFit: 'cover',
                filter: 'brightness(0.95)',
                transition: 'transform 0.3s ease',
                '&:hover': {
                  transform: 'scale(1.05)'
                }
              }} 
            />
            <Box
              sx={{
                position: 'absolute',
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                background: 'linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%)',
                pointerEvents: 'none'
              }}
            />
          </Box>
        </Box>
      </DialogContent>
    </Dialog>
  );
}
