import React, { useState } from 'react';
import Dialog from '@mui/material/Dialog';
import DialogContent from '@mui/material/DialogContent';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import TextField from '@mui/material/TextField';
import InputAdornment from '@mui/material/InputAdornment';
import Grid from '@mui/material/Grid';
import Paper from '@mui/material/Paper';
import IconButton from '@mui/material/IconButton';
import CloseIcon from '@mui/icons-material/Close';
import FavoriteIcon from '@mui/icons-material/Favorite';
import LocalCafeIcon from '@mui/icons-material/LocalCafe';
import RestaurantIcon from '@mui/icons-material/Restaurant';
import CakeIcon from '@mui/icons-material/Cake';

const PRESET_AMOUNTS = [
  { value: 100, label: '$1', icon: <LocalCafeIcon />, description: 'Un café' },
  { value: 300, label: '$3', icon: <RestaurantIcon />, description: 'Una comida' },
  { value: 500, label: '$5', icon: <CakeIcon />, description: 'Un postre' },
  { value: 1000, label: '$10', icon: <FavoriteIcon />, description: 'Gran apoyo' }
];

export default function DonationAmountDialog({ open, onClose, onConfirm }) {
  const [selectedAmount, setSelectedAmount] = useState(500); // Default $5.00
  const [customAmount, setCustomAmount] = useState('');
  const [isCustom, setIsCustom] = useState(false);
  const [loading, setLoading] = useState(false);

  const handlePresetClick = (amount) => {
    setSelectedAmount(amount);
    setIsCustom(false);
    setCustomAmount('');
  };

  const handleCustomChange = (e) => {
    const value = e.target.value;
    // Solo permitir números y punto decimal
    if (/^\d*\.?\d{0,2}$/.test(value)) {
      setCustomAmount(value);
      setIsCustom(true);
      // Convertir dólares a centavos
      const cents = Math.round(parseFloat(value || 0) * 100);
      setSelectedAmount(cents);
    }
  };

  const handleConfirm = async () => {
    const finalAmount = isCustom && customAmount ? Math.round(parseFloat(customAmount) * 100) : selectedAmount;
    
    // Validar mínimo de Stripe ($0.50 USD = 50 centavos)
    if (finalAmount < 50) {
      alert('El monto mínimo de donación es $0.50 USD');
      return;
    }

    // Guardar el monto en sessionStorage para usarlo en la página de éxito si la verificación falla
    try {
      sessionStorage.setItem('lastDonationAmount', finalAmount.toString());
      sessionStorage.setItem('lastDonationDate', new Date().toISOString());
    } catch (e) {
      console.warn('No se pudo guardar en sessionStorage:', e);
    }

    setLoading(true);
    try {
      await onConfirm(finalAmount);
    } catch (error) {
      console.error('Error al procesar donación:', error);
      setLoading(false);
    }
  };

  const formatCurrency = (cents) => {
    return `$${(cents / 100).toFixed(2)}`;
  };

  return (
    <Dialog 
      open={open} 
      onClose={onClose} 
      maxWidth="sm" 
      fullWidth
      PaperProps={{
        sx: {
          borderRadius: 3,
          overflow: 'hidden',
          boxShadow: '0 8px 32px rgba(102, 126, 234, 0.25)'
        }
      }}
    >
      {/* Header con gradiente */}
      <Box 
        sx={{ 
          background: 'linear-gradient(135deg, #667EEA 0%, #764BA2 100%)',
          p: 3,
          position: 'relative'
        }}
      >
        <IconButton
          onClick={onClose}
          sx={{
            position: 'absolute',
            right: 8,
            top: 8,
            color: 'white',
            '&:hover': { backgroundColor: 'rgba(255, 255, 255, 0.2)' }
          }}
        >
          <CloseIcon />
        </IconButton>
        
        <Box sx={{ textAlign: 'center', pt: 1 }}>
          <FavoriteIcon sx={{ fontSize: 48, color: 'white', mb: 1 }} />
          <Typography 
            variant="h5" 
            sx={{ 
              color: 'white', 
              fontFamily: 'Lato, sans-serif', 
              fontWeight: 900,
              mb: 1
            }}
          >
            Apoya Recetas del Mundo
          </Typography>
          <Typography 
            variant="body2" 
            sx={{ 
              color: 'rgba(255, 255, 255, 0.9)', 
              fontFamily: 'Open Sans, sans-serif',
              maxWidth: 400,
              mx: 'auto'
            }}
          >
            Tu donación nos ayuda a mantener el sitio funcionando y añadir nuevas funcionalidades
          </Typography>
        </Box>
      </Box>

      <DialogContent sx={{ p: 0 }}>
        <Box sx={{ p: { xs: 3, md: 4 } }}>
          {/* Montos predefinidos */}
          <Typography 
            variant="subtitle1" 
            sx={{ 
              mb: 2, 
              color: '#1A202C',
              fontFamily: 'Lato, sans-serif',
              fontWeight: 700,
              fontSize: '1.1rem'
            }}
          >
            Elige un monto
          </Typography>
          
          <Grid container spacing={2} sx={{ mb: 3 }}>
            {PRESET_AMOUNTS.map((preset) => (
              <Grid item xs={6} sm={3} key={preset.value}>
                <Paper
                  elevation={0}
                  onClick={() => handlePresetClick(preset.value)}
                  sx={{
                    p: 2,
                    textAlign: 'center',
                    cursor: 'pointer',
                    border: '2px solid',
                    borderColor: selectedAmount === preset.value && !isCustom ? '#667EEA' : '#E2E8F0',
                    borderRadius: 2,
                    background: selectedAmount === preset.value && !isCustom 
                      ? 'linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%)'
                      : '#FFFFFF',
                    transition: 'all 0.3s ease',
                    '&:hover': {
                      borderColor: '#667EEA',
                      transform: 'translateY(-4px)',
                      boxShadow: '0 8px 16px rgba(102, 126, 234, 0.2)'
                    }
                  }}
                >
                  <Box sx={{ color: selectedAmount === preset.value && !isCustom ? '#667EEA' : '#718096', mb: 1 }}>
                    {preset.icon}
                  </Box>
                  <Typography 
                    variant="h6" 
                    sx={{ 
                      fontFamily: 'Lato, sans-serif',
                      fontWeight: 900,
                      color: selectedAmount === preset.value && !isCustom ? '#667EEA' : '#1A202C',
                      mb: 0.5
                    }}
                  >
                    {preset.label}
                  </Typography>
                  <Typography 
                    variant="caption" 
                    sx={{ 
                      color: '#718096',
                      fontFamily: 'Open Sans, sans-serif',
                      display: 'block'
                    }}
                  >
                    {preset.description}
                  </Typography>
                </Paper>
              </Grid>
            ))}
          </Grid>

          {/* Monto personalizado */}
          <Typography 
            variant="subtitle1" 
            sx={{ 
              mb: 2, 
              color: '#1A202C',
              fontFamily: 'Lato, sans-serif',
              fontWeight: 700,
              fontSize: '1.1rem'
            }}
          >
            O ingresa un monto personalizado
          </Typography>
          
          <TextField
            fullWidth
            value={customAmount}
            onChange={handleCustomChange}
            placeholder="5.00"
            InputProps={{
              startAdornment: <InputAdornment position="start">$</InputAdornment>,
              sx: {
                fontFamily: 'Open Sans, sans-serif',
                fontSize: '1.2rem',
                fontWeight: 600
              }
            }}
            sx={{
              mb: 3,
              '& .MuiOutlinedInput-root': {
                borderRadius: 2,
                backgroundColor: isCustom ? 'rgba(102, 126, 234, 0.05)' : '#F7FAFC',
                '& fieldset': {
                  borderColor: isCustom ? '#667EEA' : '#E2E8F0',
                  borderWidth: 2
                },
                '&:hover fieldset': {
                  borderColor: '#667EEA'
                },
                '&.Mui-focused fieldset': {
                  borderColor: '#667EEA'
                }
              }
            }}
          />

          {/* Resumen */}
          <Paper
            elevation={0}
            sx={{
              mb: 3,
              border: '2px solid #E2E8F0',
              borderRadius: 2,
              overflow: 'hidden'
            }}
          >
            {/* Header del recibo */}
            <Box 
              sx={{ 
                background: 'linear-gradient(135deg, #667EEA 0%, #764BA2 100%)',
                p: 2,
                textAlign: 'center'
              }}
            >
              <Typography 
                variant="overline" 
                sx={{ 
                  color: 'rgba(255, 255, 255, 0.9)',
                  fontFamily: 'Open Sans, sans-serif',
                  fontWeight: 600,
                  letterSpacing: 2,
                  fontSize: '0.7rem'
                }}
              >
                RESUMEN DE DONACIÓN
              </Typography>
            </Box>

            {/* Cuerpo del recibo */}
            <Box sx={{ p: 3, backgroundColor: '#FFFFFF' }}>
              
              {/* Monto principal */}
              <Box 
                sx={{ 
                  textAlign: 'center',
                  py: 3,
                  mb: 2,
                  borderBottom: '2px dashed #E2E8F0'
                }}
              >
                <Typography 
                  variant="caption" 
                  sx={{ 
                    color: '#718096',
                    fontFamily: 'Open Sans, sans-serif',
                    fontWeight: 600,
                    textTransform: 'uppercase',
                    letterSpacing: 1,
                    display: 'block',
                    mb: 1
                  }}
                >
                  Monto Total
                </Typography>
                <Typography 
                  variant="h2" 
                  sx={{ 
                    color: '#667EEA',
                    fontFamily: 'Lato, sans-serif',
                    fontWeight: 900,
                    fontSize: { xs: '2.5rem', sm: '3rem' },
                    lineHeight: 1
                  }}
                >
                  {formatCurrency(selectedAmount)}
                </Typography>
                <Typography 
                  variant="caption" 
                  sx={{ 
                    color: '#A0AEC0',
                    fontFamily: 'monospace',
                    fontSize: '0.75rem',
                    mt: 0.5,
                    display: 'block'
                  }}
                >
                  {selectedAmount} centavos USD
                </Typography>
              </Box>

              {/* Detalles de la transacción */}
              <Box sx={{ mb: 2 }}>
                <Typography 
                  variant="caption" 
                  sx={{ 
                    color: '#718096',
                    fontFamily: 'Open Sans, sans-serif',
                    fontWeight: 600,
                    textTransform: 'uppercase',
                    letterSpacing: 0.5,
                    fontSize: '0.65rem',
                    mb: 1.5,
                    display: 'block'
                  }}
                >
                  Detalles de la Transacción
                </Typography>

                {/* Fila: Método de pago */}
                <Box 
                  sx={{ 
                    display: 'flex', 
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    py: 1,
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
                    Método de pago
                  </Typography>
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

                {/* Fila: Moneda */}
                <Box 
                  sx={{ 
                    display: 'flex', 
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    py: 1,
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
                    USD
                  </Typography>
                </Box>

                {/* Fila: Tipo */}
                <Box 
                  sx={{ 
                    display: 'flex', 
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    py: 1
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

              {/* Estado de validación */}
              <Box 
                sx={{ 
                  mt: 2,
                  pt: 2,
                  borderTop: '2px dashed #E2E8F0',
                  textAlign: 'center'
                }}
              >
                <Box
                  sx={{
                    display: 'inline-flex',
                    alignItems: 'center',
                    gap: 1,
                    px: 2.5,
                    py: 1,
                    borderRadius: 2,
                    backgroundColor: selectedAmount >= 50 ? 'rgba(72, 187, 120, 0.1)' : 'rgba(245, 101, 101, 0.1)',
                    border: `2px solid ${selectedAmount >= 50 ? '#48BB78' : '#F56565'}`
                  }}
                >
                  <Box
                    sx={{
                      width: 8,
                      height: 8,
                      borderRadius: '50%',
                      backgroundColor: selectedAmount >= 50 ? '#48BB78' : '#F56565'
                    }}
                  />
                  <Typography 
                    variant="body2" 
                    sx={{ 
                      color: selectedAmount >= 50 ? '#38A169' : '#E53E3E',
                      fontFamily: 'Open Sans, sans-serif',
                      fontWeight: 700,
                      fontSize: '0.875rem'
                    }}
                  >
                    {selectedAmount >= 50 ? 'Listo para procesar' : 'Monto mínimo requerido: $0.50'}
                  </Typography>
                </Box>
              </Box>
            </Box>

            {/* Footer del recibo */}
            <Box 
              sx={{ 
                p: 1.5, 
                backgroundColor: '#F7FAFC',
                borderTop: '1px solid #E2E8F0',
                textAlign: 'center'
              }}
            >
              <Typography 
                variant="caption" 
                sx={{ 
                  color: '#A0AEC0',
                  fontFamily: 'Open Sans, sans-serif',
                  fontSize: '0.7rem',
                  fontStyle: 'italic'
                }}
              >
                🔒 Transacción segura procesada por Stripe
              </Typography>
            </Box>
          </Paper>

          {/* Botones de acción */}
          <Box sx={{ display: 'flex', gap: 2, flexDirection: { xs: 'column', sm: 'row' } }}>
            <Button
              variant="outlined"
              onClick={onClose}
              disabled={loading}
              fullWidth
              sx={{
                py: 1.5,
                borderColor: '#E2E8F0',
                color: '#4A5568',
                fontFamily: 'Lato, sans-serif',
                fontWeight: 700,
                borderRadius: 2,
                borderWidth: 2,
                textTransform: 'none',
                fontSize: '1rem',
                '&:hover': {
                  borderColor: '#718096',
                  backgroundColor: '#F7FAFC',
                  borderWidth: 2
                }
              }}
            >
              Cancelar
            </Button>
            <Button
              variant="contained"
              onClick={handleConfirm}
              disabled={loading || selectedAmount < 50}
              fullWidth
              sx={{
                py: 1.5,
                background: 'linear-gradient(135deg, #F093FB 0%, #F5576C 100%)',
                color: 'white',
                fontFamily: 'Lato, sans-serif',
                fontWeight: 700,
                borderRadius: 2,
                textTransform: 'none',
                fontSize: '1rem',
                boxShadow: '0 4px 15px rgba(240, 147, 251, 0.4)',
                '&:hover': {
                  background: 'linear-gradient(135deg, #F5576C 0%, #F093FB 100%)',
                  transform: 'translateY(-2px)',
                  boxShadow: '0 6px 20px rgba(240, 147, 251, 0.6)'
                },
                '&:disabled': {
                  background: '#E2E8F0',
                  color: '#A0AEC0'
                }
              }}
            >
              {loading ? 'Procesando...' : 'Continuar a pago seguro'}
            </Button>
          </Box>

          {/* Información de seguridad */}
          <Box sx={{ mt: 3, textAlign: 'center' }}>
            <Typography 
              variant="caption" 
              sx={{ 
                color: '#718096',
                fontFamily: 'Open Sans, sans-serif',
                display: 'block',
                fontStyle: 'italic'
              }}
            >
              🔒 Pago seguro procesado por Stripe
            </Typography>
          </Box>
        </Box>
      </DialogContent>
    </Dialog>
  );
}
