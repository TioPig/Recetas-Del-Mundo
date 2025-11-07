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
    <Container maxWidth="md" sx={{ py: 8 }}>
      <Paper
        elevation={3}
        sx={{
          p: 6,
          textAlign: 'center',
          borderRadius: 3,
          border: '3px solid #F9E9AE',
          background: 'linear-gradient(135deg, #ffffff 0%, #FFE9E9 100%)'
        }}
      >
        <Box
          sx={{
            display: 'flex',
            justifyContent: 'center',
            mb: 3
          }}
        >
          <CancelIcon
            sx={{
              fontSize: 120,
              color: '#F75442',
              filter: 'drop-shadow(0 4px 8px rgba(0,0,0,0.2))'
            }}
          />
        </Box>

        <Typography
          variant="h3"
          gutterBottom
          sx={{
            color: '#F75442',
            fontWeight: 700,
            mb: 2
          }}
        >
          Donación Cancelada
        </Typography>

        <Typography
          variant="h6"
          sx={{
            color: '#99682E',
            mb: 4,
            fontWeight: 500
          }}
        >
          Tu donación no se ha completado. No se ha realizado ningún cargo.
        </Typography>

        <Alert
          severity="info"
          icon={<InfoIcon />}
          sx={{
            mb: 4,
            borderRadius: 2,
            border: '2px solid #F9E9AE',
            backgroundColor: 'rgba(249, 233, 174, 0.2)',
            textAlign: 'left',
            '& .MuiAlert-icon': {
              color: '#F75442'
            }
          }}
        >
          <Typography variant="body1" sx={{ color: '#99682E', fontWeight: 600, mb: 1 }}>
            No te preocupes
          </Typography>
          <Typography variant="body2" sx={{ color: '#666' }}>
            Puedes intentar donar nuevamente cuando lo desees. Tu apoyo es muy valioso para nosotros 
            y ayuda a mantener esta plataforma accesible para todos.
          </Typography>
        </Alert>

        {/* Por qué donar */}
        <Box
          sx={{
            backgroundColor: 'white',
            borderRadius: 2,
            p: 3,
            mb: 4,
            border: '3px solid #F9E9AE',
            textAlign: 'left'
          }}
        >
          <Typography 
            variant="h6" 
            sx={{ 
              color: '#F75442', 
              mb: 2, 
              fontWeight: 600,
              textAlign: 'center'
            }}
          >
            💡 ¿Por qué es importante tu donación?
          </Typography>
          
          <List dense>
            <ListItem>
              <ListItemIcon>
                <CheckCircleOutlineIcon sx={{ color: '#27ae60' }} />
              </ListItemIcon>
              <ListItemText 
                primary="Mantenemos los servidores funcionando 24/7"
                primaryTypographyProps={{ color: '#99682E' }}
              />
            </ListItem>
            <ListItem>
              <ListItemIcon>
                <CheckCircleOutlineIcon sx={{ color: '#27ae60' }} />
              </ListItemIcon>
              <ListItemText 
                primary="Mejoramos constantemente la plataforma"
                primaryTypographyProps={{ color: '#99682E' }}
              />
            </ListItem>
            <ListItem>
              <ListItemIcon>
                <CheckCircleOutlineIcon sx={{ color: '#27ae60' }} />
              </ListItemIcon>
              <ListItemText 
                primary="Agregamos nuevas recetas y funcionalidades"
                primaryTypographyProps={{ color: '#99682E' }}
              />
            </ListItem>
            <ListItem>
              <ListItemIcon>
                <CheckCircleOutlineIcon sx={{ color: '#27ae60' }} />
              </ListItemIcon>
              <ListItemText 
                primary="Ofrecemos un servicio completamente gratuito"
                primaryTypographyProps={{ color: '#99682E' }}
              />
            </ListItem>
            <ListItem>
              <ListItemIcon>
                <CheckCircleOutlineIcon sx={{ color: '#27ae60' }} />
              </ListItemIcon>
              <ListItemText 
                primary="Apoyamos a la comunidad de amantes de la cocina"
                primaryTypographyProps={{ color: '#99682E' }}
              />
            </ListItem>
          </List>

          <Box
            sx={{
              mt: 3,
              p: 2,
              backgroundColor: 'rgba(247, 84, 66, 0.05)',
              borderRadius: 2,
              border: '2px dashed #F75442'
            }}
          >
            <Typography variant="body2" sx={{ color: '#99682E', textAlign: 'center' }}>
              <strong>Cualquier aporte, grande o pequeño, hace la diferencia</strong>
            </Typography>
          </Box>
        </Box>

        {/* Botones de Acción */}
        <Stack
          direction={{ xs: 'column', sm: 'row' }}
          spacing={2}
          justifyContent="center"
        >
          <Button
            variant="contained"
            size="large"
            startIcon={<VolunteerActivismIcon />}
            onClick={handleRetryDonation}
            sx={{
              backgroundColor: '#F75442',
              color: 'white',
              px: 4,
              py: 1.5,
              fontSize: '1.1rem',
              fontWeight: 600,
              '&:hover': {
                backgroundColor: '#99682E'
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
              borderColor: '#99682E',
              color: '#99682E',
              px: 4,
              py: 1.5,
              fontSize: '1.1rem',
              fontWeight: 600,
              borderWidth: 2,
              '&:hover': {
                borderColor: '#F75442',
                color: '#F75442',
                borderWidth: 2,
                backgroundColor: 'rgba(153, 104, 46, 0.05)'
              }
            }}
          >
            Volver al Inicio
          </Button>
        </Stack>

        <Box sx={{ mt: 4, pt: 3, borderTop: '2px solid #F9E9AE' }}>
          <Typography variant="body2" sx={{ color: '#99682E', fontStyle: 'italic' }}>
            Gracias por considerar apoyar a Recetas Del Mundo.
            <br />
            Tu interés en contribuir significa mucho para nosotros. 💛
          </Typography>
        </Box>

        <Box sx={{ mt: 3 }}>
          <img
            src="/img/cheems-waso.png"
            alt="Mascota Cheems"
            style={{
              maxWidth: '120px',
              filter: 'drop-shadow(0 4px 8px rgba(0,0,0,0.2))'
            }}
          />
        </Box>
      </Paper>
    </Container>
  );
}
