import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Container from '@mui/material/Container';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import Paper from '@mui/material/Paper';
import Grid from '@mui/material/Grid';
import Alert from '@mui/material/Alert';
import Snackbar from '@mui/material/Snackbar';
import Divider from '@mui/material/Divider';
import Chip from '@mui/material/Chip';
import ImageIcon from '@mui/icons-material/Image';
import RestaurantIcon from '@mui/icons-material/Restaurant';
import FormatListNumberedIcon from '@mui/icons-material/FormatListNumbered';
import PublicIcon from '@mui/icons-material/Public';
import { postReceta, getPaises, getCategorias, isAuthenticated } from '../api';
import AuthPromptDialog from './AuthPromptDialog';

export default function NuevaReceta() {
  const navigate = useNavigate();
  const [authPromptOpen, setAuthPromptOpen] = useState(false);
  
  // Estados para el formulario
  const [nombre, setNombre] = useState('');
  const [urlImagen, setUrlImagen] = useState('');
  const [paises, setPaises] = useState([]);
  const [categorias, setCategorias] = useState([]);
  const [selectedPais, setSelectedPais] = useState(null);
  const [selectedCategoria, setSelectedCategoria] = useState(null);
  
  // Estados para ingredientes (ahora es texto)
  const [ingredientes, setIngredientes] = useState('');
  
  // Estados para preparación
  const [preparacion, setPreparacion] = useState('');
  
  // Estados para feedback
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);

  useEffect(() => {
    // Verificar autenticación
    if (!isAuthenticated()) {
      setAuthPromptOpen(true);
      return;
    }

    // Cargar países y categorías
    Promise.all([
      getPaises().catch(() => ({ data: [] })),
      getCategorias().catch(() => ({ data: [] }))
    ]).then(([paisesRes, categoriasRes]) => {
      setPaises(paisesRes?.data || []);
      setCategorias(categoriasRes?.data || []);
    });
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    // Validaciones
    if (!nombre.trim()) {
      setError('El nombre de la receta es obligatorio');
      return;
    }
    if (!selectedPais) {
      setError('Debes seleccionar un país');
      return;
    }
    if (!selectedCategoria) {
      setError('Debes seleccionar una categoría');
      return;
    }
    if (!ingredientes.trim()) {
      setError('Debes agregar ingredientes');
      return;
    }
    if (!preparacion.trim()) {
      setError('La preparación es obligatoria');
      return;
    }

    setLoading(true);

    try {
      // Obtener el usuario autenticado
      const user = JSON.parse(localStorage.getItem('user') || '{}');
      const userId = user.id_usr || user.idUsr || user.id;

      if (!userId) {
        setError('Debes iniciar sesión para crear una receta');
        setLoading(false);
        return;
      }

      const recetaData = {
        nombre: nombre.trim(),
        urlImagen: urlImagen.trim() || 'https://placehold.co/600x360',
        idPais: selectedPais.idPais || selectedPais.id,
        idCat: selectedCategoria.idCat || selectedCategoria.id,
        idUsr: userId,
        ingredientes: [{ nombre: ingredientes.trim() }],
        preparacion: preparacion.trim()
      };

      const response = await postReceta(recetaData);
      
      if (response && response.data) {
        setSuccess(true);
        // Redirigir después de 2 segundos
        setTimeout(() => {
          navigate('/mis-recetas');
        }, 2000);
      }
    } catch (err) {
      console.error('Error al crear receta:', err);
      setError(err.response?.data?.message || 'Error al crear la receta. Por favor, intenta de nuevo.');
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setNombre('');
    setUrlImagen('');
    setSelectedPais(null);
    setSelectedCategoria(null);
    setIngredientes('');
    setPreparacion('');
    setError('');
  };

  return (
    <Box>
      {/* Hero Section */}
      <Box 
        sx={{ 
          background: 'linear-gradient(135deg, #667EEA 0%, #764BA2 100%)',
          py: { xs: 4, sm: 6, md: 8 },
          boxShadow: '0 4px 20px rgba(102, 126, 234, 0.3)'
        }}
      >
        <Container>
          <Box textAlign="center">
            <Typography 
              variant="h2" 
              sx={{ 
                color: 'white',
                fontFamily: 'Lato, sans-serif', 
                fontWeight: 900,
                fontSize: { xs: '1.75rem', sm: '2.75rem', md: '3.5rem' }
              }}
            >
              Nueva Receta
            </Typography>
            <Typography 
              variant="subtitle1" 
              sx={{ 
                color: 'rgba(255, 255, 255, 0.9)',
                fontFamily: 'Open Sans, sans-serif',
                mt: 1.5,
                fontSize: { xs: '0.95rem', sm: '1.1rem', md: '1.2rem' },
                fontWeight: 500
              }}
            >
              Comparte tu receta con el mundo
            </Typography>
          </Box>
        </Container>
      </Box>

      <Container maxWidth="xl" sx={{ py: { xs: 2, sm: 4, md: 5 }, px: { xs: 2, sm: 3 }, backgroundColor: '#F7FAFC', minHeight: '100vh' }}>
        {error && (
          <Alert 
            severity="error" 
            variant="filled"
            sx={{ 
              mb: 3,
              fontFamily: 'Open Sans, sans-serif',
              fontWeight: 600
            }} 
            onClose={() => setError('')}
          >
            {error}
          </Alert>
        )}

        <Grid container spacing={{ xs: 2, sm: 3, md: 4 }} justifyContent="center">
          {/* Columna Izquierda - Formulario Principal */}
          <Grid item xs={12} lg={9}>
            {/* Información Básica */}
            <Paper 
              elevation={0} 
              sx={{ 
                p: { xs: 2.5, sm: 3.5, md: 4.5 }, 
                mb: { xs: 2, sm: 3, md: 4 }, 
                borderRadius: 3,
                border: '1px solid #E2E8F0',
                boxShadow: '0 4px 12px rgba(102, 126, 234, 0.08)'
              }}
            >
              <Box sx={{ display: 'flex', alignItems: 'center', mb: { xs: 2.5, md: 3.5 } }}>
                <ImageIcon sx={{ mr: { xs: 1.5, md: 2 }, color: '#667EEA', fontSize: { xs: 24, sm: 28, md: 32 } }} />
                <Typography 
                  variant="h6" 
                  sx={{ 
                    fontFamily: 'Lato, sans-serif', 
                    fontWeight: 900,
                    color: '#1A202C',
                    fontSize: { xs: '1.1rem', sm: '1.35rem', md: '1.6rem' }
                  }}
                >
                  Información Básica
                </Typography>
              </Box>
              
              <Divider sx={{ mb: { xs: 2, sm: 3, md: 4 }, borderColor: '#E2E8F0' }} />

              <Grid container spacing={{ xs: 2.5, md: 3.5 }}>
                <Grid item xs={12}>
                  <TextField
                    fullWidth
                    label="Nombre de la receta"
                    value={nombre}
                    onChange={(e) => setNombre(e.target.value)}
                    required
                    placeholder="Ej: Tacos al Pastor"
                    sx={{
                      '& .MuiOutlinedInput-root': {
                        borderRadius: 2,
                        fontFamily: 'Open Sans, sans-serif',
                        fontSize: { xs: '1rem', md: '1.1rem' },
                        '&.Mui-focused fieldset': {
                          borderColor: '#667EEA',
                        },
                      },
                      '& .MuiInputLabel-root': {
                        fontFamily: 'Open Sans, sans-serif',
                        fontSize: { xs: '1rem', md: '1.1rem' },
                      },
                      '& .MuiInputLabel-root.Mui-focused': {
                        color: '#667EEA',
                        fontWeight: 600
                      },
                    }}
                  />
                </Grid>

                <Grid item xs={12}>
                  <TextField
                    fullWidth
                    label="URL de la imagen (opcional)"
                    value={urlImagen}
                    onChange={(e) => setUrlImagen(e.target.value)}
                    placeholder="https://ejemplo.com/imagen.jpg"
                    sx={{
                      '& .MuiOutlinedInput-root': {
                        borderRadius: 2,
                        fontFamily: 'Open Sans, sans-serif',
                        fontSize: { xs: '1rem', md: '1.1rem' },
                        '&.Mui-focused fieldset': {
                          borderColor: '#667EEA',
                        },
                      },
                      '& .MuiInputLabel-root': {
                        fontFamily: 'Open Sans, sans-serif',
                        fontSize: { xs: '1rem', md: '1.1rem' },
                      },
                      '& .MuiInputLabel-root.Mui-focused': {
                        color: '#667EEA',
                        fontWeight: 600
                      },
                    }}
                  />
                  {urlImagen && (
                    <Box sx={{ mt: 2, textAlign: 'center' }}>
                      <Box
                        component="img"
                        src={urlImagen}
                        alt="Preview"
                        sx={{
                          maxWidth: '100%',
                          maxHeight: { xs: 180, sm: 220, md: 250 },
                          borderRadius: 3,
                          objectFit: 'cover',
                          border: '2px solid #E2E8F0',
                          boxShadow: '0 4px 12px rgba(102, 126, 234, 0.1)'
                        }}
                        onError={(e) => { e.target.src = 'https://placehold.co/600x360'; }}
                      />
                    </Box>
                  )}
                </Grid>
              </Grid>
            </Paper>

            {/* País y Categoría */}
            <Paper 
              elevation={0} 
              sx={{ 
                p: { xs: 2.5, sm: 3.5, md: 4.5 }, 
                mb: { xs: 2, sm: 3, md: 4 }, 
                borderRadius: 3,
                border: '1px solid #E2E8F0',
                boxShadow: '0 4px 12px rgba(102, 126, 234, 0.08)'
              }}
            >
              <Box sx={{ display: 'flex', alignItems: 'center', mb: { xs: 2.5, md: 3.5 } }}>
                <PublicIcon sx={{ mr: { xs: 1.5, md: 2 }, color: '#667EEA', fontSize: { xs: 24, sm: 28, md: 32 } }} />
                <Typography 
                  variant="h6" 
                  sx={{ 
                    fontFamily: 'Lato, sans-serif', 
                    fontWeight: 900,
                    color: '#1A202C',
                    fontSize: { xs: '1.1rem', sm: '1.35rem', md: '1.6rem' }
                  }}
                >
                  Clasificación
                </Typography>
              </Box>
              
              <Divider sx={{ mb: { xs: 2, sm: 3, md: 4 }, borderColor: '#E2E8F0' }} />

              <Grid container spacing={{ xs: 2.5, md: 3.5 }}>
                <Grid item xs={12}>
                  <TextField
                    fullWidth
                    select
                    label="País"
                    value={selectedPais?.idPais || selectedPais?.id || ''}
                    onChange={(e) => {
                      const paisId = parseInt(e.target.value);
                      const pais = paises.find(p => (p.idPais || p.id) === paisId);
                      setSelectedPais(pais || null);
                    }}
                    required
                    InputLabelProps={{
                      shrink: true,
                    }}
                    SelectProps={{
                      native: true,
                    }}
                    sx={{
                      '& .MuiOutlinedInput-root': {
                        borderRadius: 2,
                        fontFamily: 'Open Sans, sans-serif',
                        fontSize: { xs: '1rem', md: '1.15rem', lg: '1.2rem' },
                        '&.Mui-focused fieldset': {
                          borderColor: '#667EEA',
                        },
                      },
                      '& .MuiOutlinedInput-input': {
                        padding: { xs: '16px 14px !important', md: '20px 14px !important', lg: '22px 14px !important' }
                      },
                      '& .MuiInputLabel-root': {
                        fontFamily: 'Open Sans, sans-serif',
                        fontSize: { xs: '1rem', md: '1.15rem', lg: '1.2rem' },
                      },
                      '& .MuiInputLabel-root.Mui-focused': {
                        color: '#667EEA',
                        fontWeight: 600
                      },
                    }}
                  >
                    <option value="">Selecciona un país</option>
                    {paises.map((pais) => (
                      <option key={pais.idPais || pais.id} value={pais.idPais || pais.id}>
                        {pais.nombre}
                      </option>
                    ))}
                  </TextField>
                </Grid>

                <Grid item xs={12}>
                  <TextField
                    fullWidth
                    select
                    label="Categoría"
                    value={selectedCategoria?.idCat || selectedCategoria?.id || ''}
                    onChange={(e) => {
                      const categoriaId = parseInt(e.target.value);
                      const categoria = categorias.find(c => (c.idCat || c.id) === categoriaId);
                      setSelectedCategoria(categoria || null);
                    }}
                    required
                    InputLabelProps={{
                      shrink: true,
                    }}
                    SelectProps={{
                      native: true,
                    }}
                    sx={{
                      '& .MuiOutlinedInput-root': {
                        borderRadius: 2,
                        fontFamily: 'Open Sans, sans-serif',
                        fontSize: { xs: '1rem', md: '1.15rem', lg: '1.2rem' },
                        '&.Mui-focused fieldset': {
                          borderColor: '#667EEA',
                        },
                      },
                      '& .MuiOutlinedInput-input': {
                        padding: { xs: '16px 14px !important', md: '20px 14px !important', lg: '22px 14px !important' }
                      },
                      '& .MuiInputLabel-root': {
                        fontFamily: 'Open Sans, sans-serif',
                        fontSize: { xs: '1rem', md: '1.15rem', lg: '1.2rem' },
                      },
                      '& .MuiInputLabel-root.Mui-focused': {
                        color: '#667EEA',
                        fontWeight: 600
                      },
                    }}
                  >
                    <option value="">Selecciona una categoría</option>
                    {categorias.map((categoria) => (
                      <option key={categoria.idCat || categoria.id} value={categoria.idCat || categoria.id}>
                        {categoria.nombre}
                      </option>
                    ))}
                  </TextField>
                </Grid>
              </Grid>
            </Paper>

            {/* Ingredientes */}
            <Paper 
              elevation={0} 
              sx={{ 
                p: { xs: 2.5, sm: 3.5, md: 4.5 }, 
                mb: { xs: 2, sm: 3, md: 4 }, 
                borderRadius: 3,
                border: '1px solid #E2E8F0',
                boxShadow: '0 4px 12px rgba(102, 126, 234, 0.08)'
              }}
            >
              <Box sx={{ display: 'flex', alignItems: 'center', mb: { xs: 2.5, md: 3.5 } }}>
                <RestaurantIcon sx={{ mr: { xs: 1.5, md: 2 }, color: '#667EEA', fontSize: { xs: 24, sm: 28, md: 32 } }} />
                <Typography 
                  variant="h6" 
                  sx={{ 
                    fontFamily: 'Lato, sans-serif', 
                    fontWeight: 900,
                    color: '#1A202C',
                    fontSize: { xs: '1.1rem', sm: '1.35rem', md: '1.6rem' }
                  }}
                >
                  Ingredientes
                </Typography>
              </Box>
              
              <Divider sx={{ mb: { xs: 2, sm: 3, md: 4 }, borderColor: '#E2E8F0' }} />

              <TextField
                fullWidth
                multiline
                rows={8}
                label="Ingredientes (uno por línea)"
                value={ingredientes}
                onChange={(e) => setIngredientes(e.target.value)}
                required
                placeholder="Ejemplo:&#10;2 tazas de harina&#10;1 cucharada de azúcar&#10;500g de carne&#10;..."
                helperText="Escribe cada ingrediente en una línea separada"
                sx={{
                  '& .MuiOutlinedInput-root': {
                    borderRadius: 2,
                    fontFamily: 'Open Sans, sans-serif',
                    fontSize: { xs: '1rem', md: '1.1rem' },
                    '&.Mui-focused fieldset': {
                      borderColor: '#667EEA',
                    },
                  },
                  '& .MuiInputLabel-root': {
                    fontFamily: 'Open Sans, sans-serif',
                    fontSize: { xs: '1rem', md: '1.1rem' },
                  },
                  '& .MuiInputLabel-root.Mui-focused': {
                    color: '#667EEA',
                    fontWeight: 600
                  },
                  '& .MuiFormHelperText-root': {
                    fontFamily: 'Open Sans, sans-serif',
                    fontSize: { xs: '0.85rem', md: '0.95rem' }
                  }
                }}
              />
            </Paper>

            {/* Preparación */}
            <Paper 
              elevation={0} 
              sx={{ 
                p: { xs: 2.5, sm: 3.5, md: 4.5 }, 
                borderRadius: 3,
                border: '1px solid #E2E8F0',
                boxShadow: '0 4px 12px rgba(102, 126, 234, 0.08)'
              }}
            >
              <Box sx={{ display: 'flex', alignItems: 'center', mb: { xs: 2.5, md: 3.5 } }}>
                <FormatListNumberedIcon sx={{ mr: { xs: 1.5, md: 2 }, color: '#667EEA', fontSize: { xs: 24, sm: 28, md: 32 } }} />
                <Typography 
                  variant="h6" 
                  sx={{ 
                    fontFamily: 'Lato, sans-serif', 
                    fontWeight: 900,
                    color: '#1A202C',
                    fontSize: { xs: '1.1rem', sm: '1.35rem', md: '1.6rem' }
                  }}
                >
                  Preparación
                </Typography>
              </Box>
              
              <Divider sx={{ mb: { xs: 2, sm: 3, md: 4 }, borderColor: '#E2E8F0' }} />

              <TextField
                fullWidth
                label="Instrucciones de preparación"
                value={preparacion}
                onChange={(e) => setPreparacion(e.target.value)}
                required
                multiline
                rows={8}
                placeholder="Describe los pasos de preparación..."
                helperText="Escribe las instrucciones paso a paso"
                sx={{
                  '& .MuiOutlinedInput-root': {
                    borderRadius: 2,
                    fontFamily: 'Open Sans, sans-serif',
                    fontSize: { xs: '1rem', md: '1.1rem' },
                    '&.Mui-focused fieldset': {
                      borderColor: '#667EEA',
                    },
                  },
                  '& .MuiInputLabel-root': {
                    fontFamily: 'Open Sans, sans-serif',
                    fontSize: { xs: '1rem', md: '1.1rem' },
                  },
                  '& .MuiInputLabel-root.Mui-focused': {
                    color: '#667EEA',
                    fontWeight: 600
                  },
                  '& .MuiFormHelperText-root': {
                    fontFamily: 'Open Sans, sans-serif',
                    fontSize: { xs: '0.85rem', md: '0.95rem' }
                  }
                }}
              />
            </Paper>
          </Grid>

          {/* Columna Derecha - Resumen */}
          <Grid item xs={12} lg={3}>
            <Paper 
              elevation={0} 
              sx={{ 
                p: { xs: 2.5, sm: 3.5, md: 4, lg: 5 }, 
                borderRadius: 3,
                border: '1px solid #E2E8F0',
                boxShadow: '0 4px 12px rgba(102, 126, 234, 0.08)',
                position: { lg: 'sticky' },
                top: { lg: 20 },
                background: 'linear-gradient(135deg, rgba(102, 126, 234, 0.05) 0%, rgba(118, 75, 162, 0.05) 100%)'
              }}
            >
              <Typography 
                variant="h6" 
                sx={{ 
                  fontFamily: 'Lato, sans-serif', 
                  fontWeight: 900, 
                  mb: { xs: 2.5, md: 3, lg: 3.5 }, 
                  color: '#1A202C',
                  fontSize: { xs: '1.1rem', sm: '1.35rem', md: '1.5rem', lg: '1.65rem' }
                }}
              >
                Resumen
              </Typography>
              
              <Divider sx={{ mb: { xs: 2.5, md: 3, lg: 3.5 }, borderColor: '#E2E8F0' }} />
              
              <Box sx={{ mb: { xs: 2, md: 2.5, lg: 3 } }}>
                <Typography 
                  variant="body2" 
                  color="text.secondary" 
                  sx={{ 
                    mb: 0.5, 
                    fontSize: { xs: '0.8rem', sm: '0.875rem', md: '0.95rem', lg: '1rem' },
                    fontFamily: 'Open Sans, sans-serif',
                    fontWeight: 600,
                    color: '#667EEA'
                  }}
                >
                  Nombre
                </Typography>
                <Typography 
                  variant="body1" 
                  sx={{ 
                    fontWeight: 600, 
                    fontSize: { xs: '0.9rem', sm: '1rem', md: '1.05rem', lg: '1.15rem' },
                    fontFamily: 'Open Sans, sans-serif',
                    color: '#1A202C'
                  }}
                >
                  {nombre || 'Sin nombre'}
                </Typography>
              </Box>

              <Box sx={{ mb: { xs: 2, md: 2.5, lg: 3 } }}>
                <Typography 
                  variant="body2" 
                  color="text.secondary" 
                  sx={{ 
                    mb: 0.5, 
                    fontSize: { xs: '0.8rem', sm: '0.875rem', md: '0.95rem', lg: '1rem' },
                    fontFamily: 'Open Sans, sans-serif',
                    fontWeight: 600,
                    color: '#667EEA'
                  }}
                >
                  País
                </Typography>
                <Typography 
                  variant="body1" 
                  sx={{ 
                    fontWeight: 600, 
                    fontSize: { xs: '0.9rem', sm: '1rem', md: '1.05rem', lg: '1.15rem' },
                    fontFamily: 'Open Sans, sans-serif',
                    color: '#1A202C'
                  }}
                >
                  {selectedPais?.nombre || 'No seleccionado'}
                </Typography>
              </Box>

              <Box sx={{ mb: { xs: 2, md: 2.5, lg: 3 } }}>
                <Typography 
                  variant="body2" 
                  color="text.secondary" 
                  sx={{ 
                    mb: 0.5, 
                    fontSize: { xs: '0.8rem', sm: '0.875rem', md: '0.95rem', lg: '1rem' },
                    fontFamily: 'Open Sans, sans-serif',
                    fontWeight: 600,
                    color: '#667EEA'
                  }}
                >
                  Categoría
                </Typography>
                <Typography 
                  variant="body1" 
                  sx={{ 
                    fontWeight: 600, 
                    fontSize: { xs: '0.9rem', sm: '1rem', md: '1.05rem', lg: '1.15rem' },
                    fontFamily: 'Open Sans, sans-serif',
                    color: '#1A202C'
                  }}
                >
                  {selectedCategoria?.nombre || 'No seleccionada'}
                </Typography>
              </Box>

              <Divider sx={{ my: { xs: 2.5, md: 3, lg: 3.5 }, borderColor: '#E2E8F0' }} />

              <Box sx={{ mb: { xs: 2, md: 2.5, lg: 3 } }}>
                <Typography 
                  variant="body2" 
                  color="text.secondary" 
                  sx={{ 
                    mb: 0.5, 
                    fontSize: { xs: '0.8rem', sm: '0.875rem', md: '0.95rem', lg: '1rem' },
                    fontFamily: 'Open Sans, sans-serif',
                    fontWeight: 600,
                    color: '#667EEA'
                  }}
                >
                  Ingredientes
                </Typography>
                <Typography 
                  variant="body2" 
                  sx={{ 
                    fontSize: { xs: '0.85rem', sm: '0.9rem', md: '0.95rem', lg: '1rem' },
                    fontFamily: 'Open Sans, sans-serif',
                    color: '#718096'
                  }}
                >
                  {ingredientes.trim() ? `${ingredientes.trim().split('\n').filter(i => i.trim()).length} ingredientes` : 'Sin ingredientes'}
                </Typography>
              </Box>

              <Box sx={{ mb: { xs: 2, md: 2.5, lg: 3 } }}>
                <Typography 
                  variant="body2" 
                  color="text.secondary" 
                  sx={{ 
                    mb: 0.5, 
                    fontSize: { xs: '0.8rem', sm: '0.875rem', md: '0.95rem', lg: '1rem' },
                    fontFamily: 'Open Sans, sans-serif',
                    fontWeight: 600,
                    color: '#667EEA'
                  }}
                >
                  Preparación
                </Typography>
                <Typography 
                  variant="body2" 
                  sx={{ 
                    fontSize: { xs: '0.85rem', sm: '0.9rem', md: '0.95rem', lg: '1rem' },
                    fontFamily: 'Open Sans, sans-serif',
                    color: '#718096'
                  }}
                >
                  {preparacion.length > 0 ? `${preparacion.length} caracteres` : 'Sin preparación'}
                </Typography>
              </Box>

              <Divider sx={{ my: { xs: 2.5, md: 3, lg: 3.5 }, borderColor: '#E2E8F0' }} />

              <Box sx={{ display: 'flex', flexDirection: 'column', gap: { xs: 1.5, md: 2, lg: 2.5 } }}>
                <Button 
                  variant="contained"
                  fullWidth
                  size="large"
                  onClick={handleSubmit}
                  disabled={loading}
                  sx={{ 
                    background: 'linear-gradient(135deg, #F093FB 0%, #F5576C 100%)',
                    color: 'white',
                    fontFamily: 'Open Sans, sans-serif',
                    fontWeight: 700,
                    borderRadius: 50,
                    py: { xs: 1.5, md: 1.8, lg: 2 },
                    fontSize: { xs: '0.9rem', sm: '1rem', md: '1.05rem', lg: '1.1rem' },
                    '&:hover': {
                      background: 'linear-gradient(135deg, #F5576C 0%, #F093FB 100%)',
                      transform: 'translateY(-2px)',
                      boxShadow: '0 6px 16px rgba(240, 147, 251, 0.4)'
                    },
                    '&.Mui-disabled': {
                      background: '#E2E8F0',
                      color: '#A0AEC0'
                    },
                    transition: 'all 0.3s ease'
                  }}
                >
                  {loading ? 'Creando...' : 'Crear Receta'}
                </Button>
                
                <Button 
                  variant="outlined"
                  fullWidth
                  onClick={handleReset}
                  disabled={loading}
                  sx={{ 
                    fontSize: { xs: '0.9rem', sm: '1rem', md: '1.05rem', lg: '1.1rem' },
                    fontFamily: 'Open Sans, sans-serif',
                    fontWeight: 600,
                    borderRadius: 50,
                    borderColor: '#667EEA',
                    color: '#667EEA',
                    py: { xs: 1.2, md: 1.5, lg: 1.7 },
                    '&:hover': {
                      borderColor: '#764BA2',
                      backgroundColor: 'rgba(102, 126, 234, 0.05)',
                      transform: 'translateY(-2px)'
                    },
                    transition: 'all 0.3s ease'
                  }}
                >
                  Limpiar
                </Button>
              </Box>
            </Paper>
          </Grid>
        </Grid>
      </Container>

      <AuthPromptDialog 
        open={authPromptOpen} 
        onClose={() => {
          setAuthPromptOpen(false);
          navigate('/');
        }} 
      />

      <Snackbar
        open={success}
        autoHideDuration={3000}
        onClose={() => setSuccess(false)}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
      >
        <Alert 
          severity="success" 
          variant="filled"
          sx={{ 
            width: '100%',
            fontFamily: 'Open Sans, sans-serif',
            fontWeight: 600
          }}
        >
          Receta creada exitosamente! Redirigiendo...
        </Alert>
      </Snackbar>
    </Box>
  );
}
