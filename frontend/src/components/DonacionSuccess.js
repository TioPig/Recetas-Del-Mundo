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
          // La respuesta del backend puede contener: { session, donacion, sesion_pago }
          const { donacion, session } = response.data;
          
          if (donacion) {
            // Usar los datos reales de la donación desde el backend
            setDonationData({
              status: 'success',
              message: 'Tu donación ha sido procesada exitosamente',
              sessionId: sessionId,
              idDonacion: donacion.idDonacion || donacion.id_donacion || sessionId,
              monto: donacion.amount ? donacion.amount / 100 : 0, // Convertir centavos a dólares
              moneda: donacion.currency?.toUpperCase() || 'USD',
              fecha: donacion.fechaCreacion || donacion.fecha_creacion || new Date().toISOString(), // Dejar como array o ISO string
              estado: donacion.status === 'PAID' ? 'completado' : donacion.status?.toLowerCase() || 'completado',
              stripePaymentIntent: donacion.stripePaymentIntent || donacion.stripe_payment_intent
            });

            // Limpiar sessionStorage después de verificación exitosa
            try {
              sessionStorage.removeItem('lastDonationAmount');
              sessionStorage.removeItem('lastDonationDate');
            } catch (e) {
              console.warn('No se pudo limpiar sessionStorage:', e);
            }
          } else {
            setError('No se pudo obtener los detalles de la donación');
          }
        } else {
          setError('No se pudo verificar la donación');
        }
      } catch (err) {
        console.error('Error al verificar donación:', err);
        
        // Si el endpoint falla, usar datos guardados en sessionStorage o URL como fallback
        let amountInDollars;
        let donationDate;

        // Intentar obtener de sessionStorage primero (más confiable)
        try {
          const savedAmount = sessionStorage.getItem('lastDonationAmount');
          const savedDate = sessionStorage.getItem('lastDonationDate');
          
          if (savedAmount) {
            amountInDollars = parseFloat(savedAmount) / 100;
            donationDate = savedDate || new Date().toISOString();
          } else if (amountParam) {
            // Fallback a URL parameter
            amountInDollars = parseFloat(amountParam) / 100;
            donationDate = new Date().toISOString();
          } else {
            amountInDollars = 0.50;
            donationDate = new Date().toISOString();
          }
        } catch (e) {
          amountInDollars = amountParam ? parseFloat(amountParam) / 100 : 0.50;
          donationDate = new Date().toISOString();
        }
        
        setDonationData({ 
          status: 'success',
          message: 'Tu donación ha sido procesada exitosamente',
          sessionId: sessionId,
          idDonacion: sessionId,
          monto: amountInDollars,
          moneda: 'USD',
          fecha: donationDate,
          estado: 'completado'
        });
        
        // Mostrar advertencia pero no bloquear la UX
        setError('No se pudo verificar con el servidor, pero tu pago fue procesado por Stripe');
      } finally {
        setLoading(false);
      }
    };

    fetchDonationDetails();
  }, [sessionId, amountParam]);

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    
    console.log('📅 formatDate input:', dateString, 'type:', typeof dateString, 'isArray:', Array.isArray(dateString));
    
    // Si dateString es un array [año, mes, día, hora, minuto, segundo, nanosegundos]
    // del backend Spring Boot (LocalDateTime serializado)
    if (Array.isArray(dateString) && dateString.length >= 3) {
      const [year, month, day, hour = 0, minute = 0, second = 0] = dateString;
      // Mes en JavaScript es 0-indexed, pero el backend envía 1-indexed
      const date = new Date(year, month - 1, day, hour, minute, second);
      console.log('📅 Created date from array:', date.toString());
      return date.toLocaleDateString('es-ES', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    }
    
    // Si es una string ISO normal
    const date = new Date(dateString);
    console.log('📅 Created date from string:', date.toString());
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
    const formatted = new Intl.NumberFormat('es-ES', {
      style: 'decimal',
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }).format(amount);
    return `${currency.toUpperCase()} $${formatted}`;
  };

  if (loading) {
    return (
      <Container maxWidth="md" sx={{ py: 8, textAlign: 'center' }}>
        <CircularProgress size={60} sx={{ color: '#667EEA' }} />
        <Typography variant="h6" sx={{ mt: 3, color: '#4A5568', fontFamily: 'Open Sans, sans-serif' }}>
          Verificando tu donación con Stripe...
        </Typography>
        <Typography variant="body2" sx={{ mt: 1, color: '#718096', fontFamily: 'Open Sans, sans-serif' }}>
          Esto puede tomar unos segundos
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
            severity={error.includes('servidor') ? 'warning' : 'info'}
            sx={{ 
              mb: 3,
              borderRadius: 2,
              border: '1px solid #E2E8F0',
              fontFamily: 'Open Sans, sans-serif'
            }}
          >
            <Typography variant="body2" sx={{ fontWeight: 600, mb: 0.5 }}>
              {error.includes('servidor') ? '⚠️ Información parcial' : 'ℹ️ Nota'}
            </Typography>
            <Typography variant="body2">
              {error}
            </Typography>
          </Alert>
        )}

        {/* Baucher de Donación */}
        {donationData && (
          <Paper
            elevation={0}
            sx={{
              mb: 4,
              border: '2px solid #E2E8F0',
              borderRadius: 2,
              overflow: 'hidden',
              boxShadow: '0 8px 30px rgba(102, 126, 234, 0.15)'
            }}
          >
            {/* Header del Baucher */}
            <Box 
              sx={{ 
                background: 'linear-gradient(135deg, #667EEA 0%, #764BA2 100%)',
                p: 3,
                textAlign: 'center'
              }}
            >
              <ReceiptIcon sx={{ fontSize: 40, color: 'rgba(255, 255, 255, 0.9)', mb: 1 }} />
              <Typography 
                variant="overline" 
                sx={{ 
                  color: 'rgba(255, 255, 255, 0.95)',
                  fontFamily: 'Open Sans, sans-serif',
                  fontWeight: 700,
                  letterSpacing: 3,
                  fontSize: '0.85rem',
                  display: 'block'
                }}
              >
                RECIBO DE DONACIÓN
              </Typography>
              <Typography 
                variant="caption" 
                sx={{ 
                  color: 'rgba(255, 255, 255, 0.8)',
                  fontFamily: 'Open Sans, sans-serif',
                  fontSize: '0.7rem',
                  display: 'block',
                  mt: 0.5
                }}
              >
                Recetas Del Mundo
              </Typography>
            </Box>

            {/* Cuerpo del Baucher */}
            <Box sx={{ p: { xs: 3, md: 4 }, backgroundColor: '#FFFFFF' }}>
              
              {/* Monto Principal */}
              {donationData.monto && (
                <Box 
                  sx={{ 
                    textAlign: 'center',
                    py: 4,
                    mb: 3,
                    borderBottom: '2px dashed #E2E8F0'
                  }}
                >
                  <Typography 
                    variant="caption" 
                    sx={{ 
                      color: '#718096',
                      fontFamily: 'Open Sans, sans-serif',
                      fontWeight: 700,
                      textTransform: 'uppercase',
                      letterSpacing: 1.5,
                      display: 'block',
                      mb: 1.5
                    }}
                  >
                    Monto Total
                  </Typography>
                  <Typography 
                    variant="h1" 
                    sx={{ 
                      color: '#667EEA',
                      fontFamily: 'Lato, sans-serif',
                      fontWeight: 900,
                      fontSize: { xs: '3rem', sm: '3.5rem', md: '4rem' },
                      lineHeight: 1,
                      mb: 1
                    }}
                  >
                    {formatCurrency(donationData.monto, donationData.moneda || 'USD')}
                  </Typography>
                  <Typography 
                    variant="caption" 
                    sx={{ 
                      color: '#A0AEC0',
                      fontFamily: 'monospace',
                      fontSize: '0.75rem',
                      display: 'block'
                    }}
                  >
                    {Math.round(donationData.monto * 100)} centavos {donationData.moneda || 'USD'}
                  </Typography>
                </Box>
              )}

              {/* Detalles de la Transacción */}
              <Box sx={{ mb: 3 }}>
                <Typography 
                  variant="caption" 
                  sx={{ 
                    color: '#718096',
                    fontFamily: 'Open Sans, sans-serif',
                    fontWeight: 700,
                    textTransform: 'uppercase',
                    letterSpacing: 1,
                    fontSize: '0.7rem',
                    mb: 2,
                    display: 'block'
                  }}
                >
                  Detalles de la Transacción
                </Typography>

                {/* Fecha */}
                {donationData.fecha && (
                  <Box 
                    sx={{ 
                      display: 'flex', 
                      justifyContent: 'space-between',
                      alignItems: 'center',
                      py: 1.5,
                      borderBottom: '1px solid #F7FAFC'
                    }}
                  >
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                      <CalendarTodayIcon sx={{ color: '#667EEA', fontSize: 18 }} />
                      <Typography 
                        variant="body2" 
                        sx={{ 
                          color: '#4A5568',
                          fontFamily: 'Open Sans, sans-serif',
                          fontSize: '0.875rem'
                        }}
                      >
                        Fecha y hora
                      </Typography>
                    </Box>
                    <Typography 
                      variant="body2" 
                      sx={{ 
                        color: '#1A202C',
                        fontFamily: 'Open Sans, sans-serif',
                        fontWeight: 600,
                        fontSize: '0.875rem',
                        textAlign: 'right'
                      }}
                    >
                      {formatDate(donationData.fecha)}
                    </Typography>
                  </Box>
                )}

                {/* Método de pago */}
                <Box 
                  sx={{ 
                    display: 'flex', 
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    py: 1.5,
                    borderBottom: '1px solid #F7FAFC'
                  }}
                >
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <AttachMoneyIcon sx={{ color: '#667EEA', fontSize: 18 }} />
                    <Typography 
                      variant="body2" 
                      sx={{ 
                        color: '#4A5568',
                        fontFamily: 'Open Sans, sans-serif',
                        fontSize: '0.875rem'
                      }}
                    >
                      Método de pago
                    </Typography>
                  </Box>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                    <Box 
                      sx={{ 
                        width: 6, 
                        height: 6, 
                        borderRadius: '50%', 
                        backgroundColor: '#667EEA' 
                      }} 
                    />
                    <Typography 
                      variant="body2" 
                      sx={{ 
                        color: '#1A202C',
                        fontFamily: 'Open Sans, sans-serif',
                        fontWeight: 600,
                        fontSize: '0.875rem'
                      }}
                    >
                      Stripe
                    </Typography>
                  </Box>
                </Box>

                {/* Moneda */}
                <Box 
                  sx={{ 
                    display: 'flex', 
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    py: 1.5,
                    borderBottom: '1px solid #F7FAFC'
                  }}
                >
                  <Typography 
                    variant="body2" 
                    sx={{ 
                      color: '#4A5568',
                      fontFamily: 'Open Sans, sans-serif',
                      fontSize: '0.875rem'
                    }}
                  >
                    Moneda
                  </Typography>
                  <Typography 
                    variant="body2" 
                    sx={{ 
                      color: '#1A202C',
                      fontFamily: 'Open Sans, sans-serif',
                      fontWeight: 600,
                      fontSize: '0.875rem'
                    }}
                  >
                    {donationData.moneda || 'USD'}
                  </Typography>
                </Box>

                {/* Tipo de transacción */}
                <Box 
                  sx={{ 
                    display: 'flex', 
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    py: 1.5
                  }}
                >
                  <Typography 
                    variant="body2" 
                    sx={{ 
                      color: '#4A5568',
                      fontFamily: 'Open Sans, sans-serif',
                      fontSize: '0.875rem'
                    }}
                  >
                    Tipo de transacción
                  </Typography>
                  <Typography 
                    variant="body2" 
                    sx={{ 
                      color: '#1A202C',
                      fontFamily: 'Open Sans, sans-serif',
                      fontWeight: 600,
                      fontSize: '0.875rem'
                    }}
                  >
                    Donación
                  </Typography>
                </Box>
              </Box>

              {/* Estado de la transacción */}
              {donationData.estado && (
                <Box 
                  sx={{ 
                    pt: 3,
                    borderTop: '2px dashed #E2E8F0',
                    textAlign: 'center'
                  }}
                >
                  <Box
                    sx={{
                      display: 'inline-flex',
                      alignItems: 'center',
                      gap: 1.5,
                      px: 4,
                      py: 2,
                      borderRadius: 2,
                      backgroundColor: 'rgba(72, 187, 120, 0.1)',
                      border: '2px solid #48BB78'
                    }}
                  >
                    <CheckCircleIcon sx={{ color: '#48BB78', fontSize: 24 }} />
                    <Typography 
                      variant="body1" 
                      sx={{ 
                        color: '#38A169',
                        fontFamily: 'Lato, sans-serif',
                        fontWeight: 700,
                        fontSize: '1rem'
                      }}
                    >
                      {donationData.estado === 'completado' ? 'PAGO CONFIRMADO' : donationData.estado.toUpperCase()}
                    </Typography>
                  </Box>
                </Box>
              )}

              {/* ID de Referencia */}
              {donationData.idDonacion && (
                <Box 
                  sx={{ 
                    mt: 3,
                    pt: 3,
                    borderTop: '1px solid #E2E8F0'
                  }}
                >
                  <Typography 
                    variant="caption" 
                    sx={{ 
                      color: '#718096',
                      fontFamily: 'Open Sans, sans-serif',
                      fontWeight: 700,
                      textTransform: 'uppercase',
                      letterSpacing: 1,
                      fontSize: '0.65rem',
                      mb: 1,
                      display: 'block'
                    }}
                  >
                    ID de Referencia
                  </Typography>
                  <Typography 
                    variant="body2" 
                    sx={{ 
                      color: '#4A5568',
                      fontFamily: 'monospace',
                      backgroundColor: '#F7FAFC',
                      p: 1.5,
                      borderRadius: 1,
                      fontSize: '0.75rem',
                      wordBreak: 'break-all',
                      border: '1px solid #E2E8F0'
                    }}
                  >
                    {donationData.idDonacion}
                  </Typography>
                  
                  {donationData.stripePaymentIntent && (
                    <>
                      <Typography 
                        variant="caption" 
                        sx={{ 
                          color: '#718096',
                          fontFamily: 'Open Sans, sans-serif',
                          fontWeight: 700,
                          textTransform: 'uppercase',
                          letterSpacing: 1,
                          fontSize: '0.65rem',
                          mb: 1,
                          mt: 2,
                          display: 'block'
                        }}
                      >
                        Payment Intent ID
                      </Typography>
                      <Typography 
                        variant="body2" 
                        sx={{ 
                          color: '#4A5568',
                          fontFamily: 'monospace',
                          backgroundColor: '#F7FAFC',
                          p: 1.5,
                          borderRadius: 1,
                          fontSize: '0.75rem',
                          wordBreak: 'break-all',
                          border: '1px solid #E2E8F0'
                        }}
                      >
                        {donationData.stripePaymentIntent}
                      </Typography>
                    </>
                  )}
                </Box>
              )}
            </Box>

            {/* Footer del Baucher */}
            <Box 
              sx={{ 
                p: 2, 
                backgroundColor: '#F7FAFC',
                borderTop: '2px solid #E2E8F0',
                textAlign: 'center'
              }}
            >
              <Typography 
                variant="caption" 
                sx={{ 
                  color: '#718096',
                  fontFamily: 'Open Sans, sans-serif',
                  fontSize: '0.7rem',
                  display: 'block',
                  mb: 0.5
                }}
              >
                🔒 Transacción segura procesada por Stripe
              </Typography>
              <Typography 
                variant="caption" 
                sx={{ 
                  color: '#A0AEC0',
                  fontFamily: 'Open Sans, sans-serif',
                  fontSize: '0.65rem',
                  fontStyle: 'italic'
                }}
              >
                Conserva este recibo para tus registros
              </Typography>
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
