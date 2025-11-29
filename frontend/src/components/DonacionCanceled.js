import React from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Container,
  Box,
  Typography,
  Button,
  Paper,
  Stack,
  Alert,
  List,
  ListItem,
  ListItemIcon,
  ListItemText
} from '@mui/material';
import CancelIcon from '@mui/icons-material/Cancel';
import HomeIcon from '@mui/icons-material/Home';
import VolunteerActivismIcon from '@mui/icons-material/VolunteerActivism';
import InfoIcon from '@mui/icons-material/Info';
import CheckCircleOutlineIcon from '@mui/icons-material/CheckCircleOutline';

export default function DonacionCanceled() {
  const navigate = useNavigate();

  const handleRetryDonation = () => {
    // Redirigir al inicio donde está el botón de donar
    navigate('/');
    
    // Scroll al header después de un pequeño delay
    setTimeout(() => {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }, 100);
  };

  return (
    <Box sx={{ backgroundColor: '#F7FAFC', minHeight: '100vh', pb: { xs: 4, md: 8 } }}>
      {/* Hero Section */}
      <Box 
        sx={{ 
          textAlign: 'center', 
          background: 'linear-gradient(135deg, #F56565 0%, #E53E3E 100%)',
          py: { xs: 4, sm: 6, md: 8 },
          mb: { xs: 4, md: 6 },
          boxShadow: '0 4px 20px rgba(245, 101, 101, 0.3)'
        }}
      >
        <CancelIcon
          sx={{
            fontSize: { xs: 80, md: 120 },
            color: '#FFFFFF',
            filter: 'drop-shadow(0 4px 8px rgba(0,0,0,0.2))',
            mb: 2
          }}
        />
        <Typography 
          variant="h2" 
          sx={{ 
            color: '#FFFFFF', 
            fontFamily: 'Lato, sans-serif', 
            fontWeight: 900,
            fontSize: { xs: '2rem', sm: '2.5rem', md: '3rem' },
            mb: 2
          }}
        >
          Donación Cancelada
        </Typography>
        <Typography
          variant="h6"
          sx={{
            color: 'rgba(255, 255, 255, 0.95)',
            fontFamily: 'Open Sans, sans-serif',
            fontSize: { xs: '1rem', sm: '1.1rem', md: '1.2rem' },
            maxWidth: 600,
            mx: 'auto',
            px: 2
          }}
        >
          Tu donación no se ha completado. No se ha realizado ningún cargo.
        </Typography>
      </Box>

      <Container maxWidth="md">
        <Alert
          severity="info"
          icon={<InfoIcon />}
          sx={{
            mb: 4,
            borderRadius: 2,
            border: '1px solid #E2E8F0',
            backgroundColor: 'rgba(66, 153, 225, 0.08)',
            fontFamily: 'Open Sans, sans-serif',
            '& .MuiAlert-icon': {
              color: '#4299E1'
            }
          }}
        >
          <Typography variant="body1" sx={{ color: '#1A202C', fontWeight: 600, mb: 1 }}>
            No te preocupes
          </Typography>
          <Typography variant="body2" sx={{ color: '#4A5568' }}>
            Puedes intentar donar nuevamente cuando lo desees. Tu apoyo es muy valioso para nosotros 
            y ayuda a mantener esta plataforma accesible para todos.
          </Typography>
        </Alert>

        {/* Por qué donar */}
        <Paper
          elevation={0}
          sx={{
            backgroundColor: '#FFFFFF',
            borderRadius: 3,
            p: { xs: 3, md: 4 },
            mb: 4,
            border: '1px solid #E2E8F0',
            boxShadow: '0 4px 20px rgba(102, 126, 234, 0.1)'
          }}
        >
          <Typography 
            variant="h5" 
            sx={{ 
              color: '#667EEA', 
              fontFamily: 'Lato, sans-serif',
              mb: 3, 
              fontWeight: 700,
              textAlign: 'center',
              fontSize: { xs: '1.3rem', md: '1.5rem' }
            }}
          >
            💡 ¿Por qué es importante tu donación?
          </Typography>
          
          <List dense>
            <ListItem>
              <ListItemIcon>
                <CheckCircleOutlineIcon sx={{ color: '#48BB78' }} />
              </ListItemIcon>
              <ListItemText 
                primary="Mantenemos los servidores funcionando 24/7"
                primaryTypographyProps={{ 
                  color: '#4A5568',
                  fontFamily: 'Open Sans, sans-serif',
                  fontWeight: 500
                }}
              />
            </ListItem>
            <ListItem>
              <ListItemIcon>
                <CheckCircleOutlineIcon sx={{ color: '#48BB78' }} />
              </ListItemIcon>
              <ListItemText 
                primary="Mejoramos constantemente la plataforma"
                primaryTypographyProps={{ 
                  color: '#4A5568',
                  fontFamily: 'Open Sans, sans-serif',
                  fontWeight: 500
                }}
              />
            </ListItem>
            <ListItem>
              <ListItemIcon>
                <CheckCircleOutlineIcon sx={{ color: '#48BB78' }} />
              </ListItemIcon>
              <ListItemText 
                primary="Agregamos nuevas recetas y funcionalidades"
                primaryTypographyProps={{ 
                  color: '#4A5568',
                  fontFamily: 'Open Sans, sans-serif',
                  fontWeight: 500
                }}
              />
            </ListItem>
            <ListItem>
              <ListItemIcon>
                <CheckCircleOutlineIcon sx={{ color: '#48BB78' }} />
              </ListItemIcon>
              <ListItemText 
                primary="Ofrecemos un servicio completamente gratuito"
                primaryTypographyProps={{ 
                  color: '#4A5568',
                  fontFamily: 'Open Sans, sans-serif',
                  fontWeight: 500
                }}
              />
            </ListItem>
            <ListItem>
              <ListItemIcon>
                <CheckCircleOutlineIcon sx={{ color: '#48BB78' }} />
              </ListItemIcon>
              <ListItemText 
                primary="Apoyamos a la comunidad de amantes de la cocina"
                primaryTypographyProps={{ 
                  color: '#4A5568',
                  fontFamily: 'Open Sans, sans-serif',
                  fontWeight: 500
                }}
              />
            </ListItem>
          </List>

          <Paper
            elevation={0}
            sx={{
              mt: 3,
              p: 2.5,
              background: 'linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%)',
              borderRadius: 2,
              border: '2px dashed #667EEA'
            }}
          >
            <Typography 
              variant="body1" 
              sx={{ 
                color: '#1A202C', 
                fontFamily: 'Lato, sans-serif',
                textAlign: 'center',
                fontWeight: 600
              }}
            >
              Cualquier aporte, grande o pequeño, hace la diferencia ✨
            </Typography>
          </Paper>
        </Paper>

        {/* Botones de Acción */}
        <Stack
          direction={{ xs: 'column', sm: 'row' }}
          spacing={2}
          justifyContent="center"
          sx={{ mb: 4 }}
        >
          <Button
            variant="contained"
            size="large"
            startIcon={<VolunteerActivismIcon />}
            onClick={handleRetryDonation}
            sx={{
              background: 'linear-gradient(135deg, #F093FB 0%, #F5576C 100%)',
              color: '#FFFFFF',
              fontFamily: 'Lato, sans-serif',
              fontWeight: 700,
              px: 4,
              py: 1.8,
              fontSize: { xs: '1rem', md: '1.1rem' },
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
            Intentar de Nuevo
          </Button>

          <Button
            variant="outlined"
            size="large"
            startIcon={<HomeIcon />}
            onClick={() => navigate('/')}
            sx={{
              borderColor: '#667EEA',
              color: '#667EEA',
              fontFamily: 'Lato, sans-serif',
              fontWeight: 700,
              px: 4,
              py: 1.8,
              fontSize: { xs: '1rem', md: '1.1rem' },
              borderRadius: 2,
              textTransform: 'none',
              borderWidth: 2,
              transition: 'all 0.3s ease',
              '&:hover': {
                borderColor: '#764BA2',
                backgroundColor: 'rgba(102, 126, 234, 0.08)',
                transform: 'translateY(-2px)',
                borderWidth: 2
              }
            }}
          >
            Volver al Inicio
          </Button>
        </Stack>

        <Paper
          elevation={0}
          sx={{
            p: 4,
            borderRadius: 3,
            border: '1px solid #E2E8F0',
            backgroundColor: '#FFFFFF',
            textAlign: 'center'
          }}
        >
          <Typography 
            variant="body1" 
            sx={{ 
              color: '#4A5568', 
              fontFamily: 'Open Sans, sans-serif',
              fontStyle: 'italic',
              mb: 3,
              fontSize: { xs: '0.95rem', md: '1rem' }
            }}
          >
            Gracias por considerar apoyar a Recetas Del Mundo.
            <br />
            Tu interés en contribuir significa mucho para nosotros. 💛
          </Typography>

          <Box sx={{ mt: 3 }}>
            <img
              src="/img/cheems-waso.png"
              alt="Mascota Cheems"
              style={{
                maxWidth: '120px',
                filter: 'drop-shadow(0 4px 8px rgba(0,0,0,0.1))'
              }}
            />
          </Box>
        </Paper>
      </Container>
    </Box>
  );
}
