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
  const amountParam = searchParams.get('amount'); // ⬅️ Obtener monto de la URL
  
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
        
        // Si el endpoint no existe, usar los datos de la URL y Stripe
        // Convertir centavos a dólares (el backend envía en centavos)
        const amountInDollars = amountParam ? parseFloat(amountParam) / 100 : 0.50;
        
        setDonationData({ 
          status: 'success',
          message: 'Tu donación ha sido procesada exitosamente',
          sessionId: sessionId,
          idDonacion: sessionId,
          monto: amountInDollars,
          moneda: 'USD',
          fecha: new Date().toISOString(),
          estado: 'completado'
        });
      } finally {
        setLoading(false);
      }
    };

    fetchDonationDetails();
  }, [sessionId, amountParam]); // ⬅️ Agregar amountParam a las dependencias

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
        <CircularProgress size={60} sx={{ color: '#667EEA' }} />
        <Typography variant="h6" sx={{ mt: 3, color: '#4A5568', fontFamily: 'Open Sans, sans-serif' }}>
          Verificando tu donación...
        </Typography>
      </Container>
    );
  }

  return (
    <Box sx={{ backgroundColor: '#F7FAFC', minHeight: '100vh', pb: { xs: 4, md: 8 } }}>
      {/* Hero Section */}
      <Box 
        sx={{ 
          textAlign: 'center', 
          background: 'linear-gradient(135deg, #667EEA 0%, #764BA2 100%)',
          py: { xs: 4, sm: 6, md: 8 },
          mb: { xs: 4, md: 6 },
          boxShadow: '0 4px 20px rgba(102, 126, 234, 0.3)'
        }}
      >
        <CheckCircleIcon
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
          ¡Gracias por tu donación!
        </Typography>
        <Typography
          variant="h6"
          sx={{
            color: 'rgba(255, 255, 255, 0.95)',
            fontFamily: 'Open Sans, sans-serif',
            fontSize: { xs: '1rem', sm: '1.1rem', md: '1.2rem' },
            maxWidth: 700,
            mx: 'auto',
            px: 2
          }}
        >
          Tu apoyo nos ayuda a mantener Recetas Del Mundo funcionando y mejorando cada día
        </Typography>
      </Box>

      <Container maxWidth="md">
        {error && (
          <Alert 
            severity="warning" 
            sx={{ 
              mb: 3,
              borderRadius: 2,
              border: '1px solid #E2E8F0',
              fontFamily: 'Open Sans, sans-serif'
            }}
          >
            {error}
          </Alert>
        )}

        {/* Detalles de la Donación */}
        {donationData && (
          <Paper
            elevation={0}
            sx={{
              mb: 4,
              backgroundColor: '#FFFFFF',
              border: '1px solid #E2E8F0',
              borderRadius: 3,
              boxShadow: '0 4px 20px rgba(102, 126, 234, 0.1)',
              overflow: 'hidden'
            }}
          >
            <Box 
              sx={{ 
                background: 'linear-gradient(135deg, #F093FB 0%, #F5576C 100%)',
                p: 3,
                textAlign: 'center'
              }}
            >
              <Typography 
                variant="h5" 
                sx={{ 
                  color: '#FFFFFF', 
                  fontFamily: 'Lato, sans-serif',
                  fontWeight: 700,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: 1,
                  fontSize: { xs: '1.3rem', md: '1.5rem' }
                }}
              >
                <ReceiptIcon /> Resumen de tu Donación
              </Typography>
            </Box>

            <Box sx={{ p: { xs: 3, md: 4 } }}>
              <Grid container spacing={3}>
                {/* Monto */}
                {donationData.monto && (
                  <Grid item xs={12} sm={6}>
                    <Paper 
                      elevation={0}
                      sx={{ 
                        p: 3, 
                        background: 'linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%)',
                        borderRadius: 2,
                        border: '2px solid #E2E8F0',
                        textAlign: 'center'
                      }}
                    >
                      <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 0.5, mb: 1 }}>
                        <AttachMoneyIcon sx={{ color: '#667EEA', fontSize: 20 }} />
                        <Typography 
                          variant="caption" 
                          sx={{ 
                            color: '#4A5568',
                            fontFamily: 'Open Sans, sans-serif',
                            fontWeight: 600,
                            textTransform: 'uppercase',
                            letterSpacing: 0.5
                          }}
                        >
                          Monto
                        </Typography>
                      </Box>
                      <Typography 
                        variant="h4" 
                        sx={{ 
                          color: '#667EEA', 
                          fontFamily: 'Lato, sans-serif',
                          fontWeight: 900,
                          fontSize: { xs: '1.8rem', md: '2.125rem' }
                        }}
                      >
                        {formatCurrency(donationData.monto, donationData.moneda || 'USD')}
                      </Typography>
                    </Paper>
                  </Grid>
                )}

                {/* Fecha */}
                {donationData.fecha && (
                  <Grid item xs={12} sm={6}>
                    <Paper 
                      elevation={0}
                      sx={{ 
                        p: 3, 
                        background: 'linear-gradient(135deg, rgba(240, 147, 251, 0.1) 0%, rgba(245, 87, 108, 0.1) 100%)',
                        borderRadius: 2,
                        border: '2px solid #E2E8F0',
                        textAlign: 'center'
                      }}
                    >
                      <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 0.5, mb: 1 }}>
                        <CalendarTodayIcon sx={{ color: '#F5576C', fontSize: 20 }} />
                        <Typography 
                          variant="caption" 
                          sx={{ 
                            color: '#4A5568',
                            fontFamily: 'Open Sans, sans-serif',
                            fontWeight: 600,
                            textTransform: 'uppercase',
                            letterSpacing: 0.5
                          }}
                        >
                          Fecha
                        </Typography>
                      </Box>
                      <Typography 
                        variant="body1" 
                        sx={{ 
                          color: '#1A202C', 
                          fontFamily: 'Open Sans, sans-serif',
                          fontWeight: 600,
                          fontSize: { xs: '0.9rem', md: '1rem' }
                        }}
                      >
                        {formatDate(donationData.fecha)}
                      </Typography>
                    </Paper>
                  </Grid>
                )}

                {/* ID de Donación */}
                {donationData.idDonacion && (
                  <Grid item xs={12}>
                    <Paper 
                      elevation={0}
                      sx={{ 
                        p: 3, 
                        backgroundColor: '#F7FAFC',
                        borderRadius: 2,
                        border: '2px dashed #667EEA'
                      }}
                    >
                      <Typography 
                        variant="caption" 
                        sx={{ 
                          color: '#4A5568',
                          fontFamily: 'Open Sans, sans-serif',
                          fontWeight: 600,
                          mb: 1,
                          display: 'block',
                          textTransform: 'uppercase',
                          letterSpacing: 0.5
                        }}
                      >
                        ID de Referencia
                      </Typography>
                      <Typography 
                        variant="body2" 
                        sx={{ 
                          color: '#718096',
                          fontFamily: 'monospace',
                          backgroundColor: '#FFFFFF',
                          p: 1.5,
                          borderRadius: 1,
                          display: 'inline-block',
                          border: '1px solid #E2E8F0'
                        }}
                      >
                        {donationData.idDonacion}
                      </Typography>
                    </Paper>
                  </Grid>
                )}

                {/* Estado */}
                {donationData.estado && (
                  <Grid item xs={12}>
                    <Paper 
                      elevation={0}
                      sx={{ 
                        p: 2.5, 
                        background: 'linear-gradient(135deg, rgba(72, 187, 120, 0.1) 0%, rgba(56, 161, 105, 0.1) 100%)',
                        borderRadius: 2,
                        border: '2px solid #48BB78',
                        textAlign: 'center'
                      }}
                    >
                      <Typography 
                        variant="body1" 
                        sx={{ 
                          color: '#38A169', 
                          fontFamily: 'Lato, sans-serif',
                          fontWeight: 700,
                          fontSize: { xs: '1rem', md: '1.1rem' }
                        }}
                      >
                        ✓ Estado: {donationData.estado === 'completado' ? 'Pago Confirmado' : donationData.estado}
                      </Typography>
                    </Paper>
                  </Grid>
                )}
              </Grid>

              {sessionId && (
                <Box sx={{ mt: 3, pt: 3, borderTop: '1px solid #E2E8F0', textAlign: 'center' }}>
                  <Typography variant="caption" sx={{ color: '#A0AEC0', fontFamily: 'monospace' }}>
                    Session ID: {sessionId.substring(0, 30)}...
                  </Typography>
                </Box>
              )}
            </Box>
          </Paper>
        )}

        {/* Información Adicional */}
        <Alert
          icon={<EmailIcon />}
          severity="info"
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
          <Typography variant="body2" sx={{ fontWeight: 600, mb: 1, color: '#1A202C' }}>
            📧 Confirmación por correo
          </Typography>
          <Typography variant="body2" sx={{ color: '#4A5568' }}>
            Recibirás un correo electrónico con los detalles completos de tu donación 
            y un recibo para tus registros.
          </Typography>
        </Alert>

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
            startIcon={<HomeIcon />}
            onClick={() => navigate('/')}
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
            Volver al Inicio
          </Button>

          <Button
            variant="outlined"
            size="large"
            startIcon={<RestaurantIcon />}
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
            Explorar Recetas
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
            💚 Tu generosidad hace posible que miles de usuarios disfruten de recetas 
            deliciosas de todo el mundo. <strong>¡Muchas gracias!</strong>
          </Typography>

          <Box sx={{ mt: 3 }}>
            <img
              src="/img/Eat-and-Enjoy-8.png"
              alt="Eat and Enjoy"
              style={{
                maxWidth: '150px',
                filter: 'drop-shadow(0 4px 8px rgba(0,0,0,0.1))'
              }}
            />
          </Box>
        </Paper>
      </Container>
    </Box>
  );
}
