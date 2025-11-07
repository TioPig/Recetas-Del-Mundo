import React, { useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import {
  Container,
  Box,
  Typography,
  Button,
  Paper,
  Stack,
  CircularProgress,
  Alert,
  Divider,
  Card,
  CardContent,
  Grid
} from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import HomeIcon from '@mui/icons-material/Home';
import RestaurantIcon from '@mui/icons-material/Restaurant';
import AttachMoneyIcon from '@mui/icons-material/AttachMoney';
import CalendarTodayIcon from '@mui/icons-material/CalendarToday';
import ReceiptIcon from '@mui/icons-material/Receipt';
import EmailIcon from '@mui/icons-material/Email';
import { verifyDonation } from '../api';

export default function DonacionSuccess() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const sessionId = searchParams.get('session_id');
  
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [donationData, setDonationData] = useState(null);

  useEffect(() => {
    const fetchDonationDetails = async () => {
      if (!sessionId) {
        setError('No se encontró información de la sesión de pago');
        setLoading(false);
        return;
      }

      try {
        const response = await verifyDonation(sessionId);
        
        if (response.data) {
          setDonationData(response.data);
        } else {
          setError('No se pudo verificar la donación');
        }
      } catch (err) {
        console.error('Error al verificar donación:', err);
        // Incluso si falla la verificación, mostramos mensaje genérico de éxito
        setDonationData({ 
          status: 'success',
          message: 'Tu donación ha sido procesada exitosamente'
        });
      } finally {
        setLoading(false);
      }
    };

    fetchDonationDetails();
  }, [sessionId]);

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const formatCurrency = (amount, currency = 'USD') => {
    if (!amount) return 'N/A';
    return new Intl.NumberFormat('es-ES', {
      style: 'currency',
      currency: currency.toUpperCase()
    }).format(amount);
  };

  if (loading) {
    return (
      <Container maxWidth="md" sx={{ py: 8, textAlign: 'center' }}>
        <CircularProgress size={60} sx={{ color: '#F75442' }} />
        <Typography variant="h6" sx={{ mt: 3, color: '#99682E' }}>
          Verificando tu donación...
        </Typography>
      </Container>
    );
  }

  return (
    <Container maxWidth="md" sx={{ py: 8 }}>
      <Paper
        elevation={3}
        sx={{
          p: 6,
          textAlign: 'center',
          borderRadius: 3,
          border: '3px solid #F9E9AE',
          background: 'linear-gradient(135deg, #ffffff 0%, #F9E9AE 100%)'
        }}
      >
        <Box
          sx={{
            display: 'flex',
            justifyContent: 'center',
            mb: 3
          }}
        >
          <CheckCircleIcon
            sx={{
              fontSize: 120,
              color: '#27ae60',
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
          ¡Gracias por tu donación!
        </Typography>

        <Typography
          variant="h6"
          sx={{
            color: '#99682E',
            mb: 4,
            fontWeight: 500
          }}
        >
          Tu apoyo nos ayuda a mantener Recetas Del Mundo funcionando y mejorando cada día.
        </Typography>

        {error && (
          <Alert 
            severity="warning" 
            sx={{ 
              mb: 3,
              borderRadius: 2,
              border: '2px solid #F9E9AE'
            }}
          >
            {error}
          </Alert>
        )}

        {/* Detalles de la Donación */}
        {donationData && (
          <Card
            sx={{
              mb: 4,
              backgroundColor: 'white',
              border: '3px solid #F75442',
              borderRadius: 2,
              boxShadow: '0 4px 12px rgba(247, 84, 66, 0.2)'
            }}
          >
            <CardContent sx={{ p: 3 }}>
              <Typography 
                variant="h5" 
                sx={{ 
                  color: '#F75442', 
                  fontWeight: 600, 
                  mb: 3,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: 1
                }}
              >
                <ReceiptIcon /> Resumen de tu Donación
              </Typography>

              <Divider sx={{ mb: 3, borderColor: '#F9E9AE' }} />

              <Grid container spacing={2}>
                {/* Monto */}
                {donationData.monto && (
                  <Grid item xs={12} sm={6}>
                    <Box sx={{ 
                      p: 2, 
                      backgroundColor: 'rgba(247, 84, 66, 0.05)',
                      borderRadius: 2,
                      border: '2px solid #F9E9AE'
                    }}>
                      <Typography 
                        variant="caption" 
                        sx={{ 
                          color: '#99682E',
                          fontWeight: 600,
                          display: 'flex',
                          alignItems: 'center',
                          gap: 0.5,
                          mb: 1
                        }}
                      >
                        <AttachMoneyIcon fontSize="small" /> Monto
                      </Typography>
                      <Typography variant="h4" sx={{ color: '#F75442', fontWeight: 700 }}>
                        {formatCurrency(donationData.monto, donationData.moneda || 'USD')}
                      </Typography>
                    </Box>
                  </Grid>
                )}

                {/* Fecha */}
                {donationData.fecha && (
                  <Grid item xs={12} sm={6}>
                    <Box sx={{ 
                      p: 2, 
                      backgroundColor: 'rgba(153, 104, 46, 0.05)',
                      borderRadius: 2,
                      border: '2px solid #F9E9AE'
                    }}>
                      <Typography 
                        variant="caption" 
                        sx={{ 
                          color: '#99682E',
                          fontWeight: 600,
                          display: 'flex',
                          alignItems: 'center',
                          gap: 0.5,
                          mb: 1
                        }}
                      >
                        <CalendarTodayIcon fontSize="small" /> Fecha
                      </Typography>
                      <Typography variant="body1" sx={{ color: '#99682E', fontWeight: 600 }}>
                        {formatDate(donationData.fecha)}
                      </Typography>
                    </Box>
                  </Grid>
                )}

                {/* ID de Donación */}
                {donationData.idDonacion && (
                  <Grid item xs={12}>
                    <Box sx={{ 
                      p: 2, 
                      backgroundColor: 'rgba(249, 233, 174, 0.3)',
                      borderRadius: 2,
                      border: '2px dashed #F75442'
                    }}>
                      <Typography 
                        variant="caption" 
                        sx={{ 
                          color: '#99682E',
                          fontWeight: 600,
                          mb: 1,
                          display: 'block'
                        }}
                      >
                        ID de Referencia
                      </Typography>
                      <Typography 
                        variant="body2" 
                        sx={{ 
                          color: '#666',
                          fontFamily: 'monospace',
                          backgroundColor: 'white',
                          p: 1,
                          borderRadius: 1,
                          display: 'inline-block'
                        }}
                      >
                        {donationData.idDonacion}
                      </Typography>
                    </Box>
                  </Grid>
                )}

                {/* Estado */}
                {donationData.estado && (
                  <Grid item xs={12}>
                    <Box sx={{ 
                      p: 2, 
                      backgroundColor: 'rgba(39, 174, 96, 0.1)',
                      borderRadius: 2,
                      border: '2px solid #27ae60'
                    }}>
                      <Typography variant="body1" sx={{ color: '#27ae60', fontWeight: 600 }}>
                        ✓ Estado: {donationData.estado === 'completado' ? 'Pago Confirmado' : donationData.estado}
                      </Typography>
                    </Box>
                  </Grid>
                )}
              </Grid>

              {sessionId && (
                <Box sx={{ mt: 3, pt: 2, borderTop: '1px solid #F9E9AE' }}>
                  <Typography variant="caption" sx={{ color: '#999' }}>
                    Session ID: {sessionId.substring(0, 30)}...
                  </Typography>
                </Box>
              )}
            </CardContent>
          </Card>
        )}

        {/* Información Adicional */}
        <Alert
          icon={<EmailIcon />}
          severity="info"
          sx={{
            mb: 4,
            borderRadius: 2,
            border: '2px solid #F9E9AE',
            backgroundColor: 'rgba(52, 152, 219, 0.05)',
            textAlign: 'left'
          }}
        >
          <Typography variant="body2" sx={{ fontWeight: 600, mb: 1 }}>
            📧 Confirmación por correo
          </Typography>
          <Typography variant="body2">
            Recibirás un correo electrónico con los detalles completos de tu donación 
            y un recibo para tus registros.
          </Typography>
        </Alert>

        {/* Botones de Acción */}
        <Stack
          direction={{ xs: 'column', sm: 'row' }}
          spacing={2}
          justifyContent="center"
        >
          <Button
            variant="contained"
            size="large"
            startIcon={<HomeIcon />}
            onClick={() => navigate('/')}
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
            Volver al Inicio
          </Button>

          <Button
            variant="outlined"
            size="large"
            startIcon={<RestaurantIcon />}
            onClick={() => navigate('/')}
            sx={{
              borderColor: '#F75442',
              color: '#F75442',
              px: 4,
              py: 1.5,
              fontSize: '1.1rem',
              fontWeight: 600,
              borderWidth: 2,
              '&:hover': {
                borderColor: '#99682E',
                color: '#99682E',
                borderWidth: 2,
                backgroundColor: 'rgba(247, 84, 66, 0.05)'
              }
            }}
          >
            Explorar Recetas
          </Button>
        </Stack>

        <Box sx={{ mt: 4, pt: 3, borderTop: '2px solid #F9E9AE' }}>
          <Typography variant="body2" sx={{ color: '#99682E', fontStyle: 'italic' }}>
            💚 Tu generosidad hace posible que miles de usuarios disfruten de recetas 
            deliciosas de todo el mundo. ¡Muchas gracias!
          </Typography>
        </Box>

        <Box sx={{ mt: 3 }}>
          <img
            src="/img/Eat-and-Enjoy-8.png"
            alt="Eat and Enjoy"
            style={{
              maxWidth: '150px',
              filter: 'drop-shadow(0 4px 8px rgba(0,0,0,0.2))'
            }}
          />
        </Box>
      </Paper>
    </Container>
  );
}
