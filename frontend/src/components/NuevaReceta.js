import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Container from '@mui/material/Container';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import Paper from '@mui/material/Paper';
import Grid from '@mui/material/Grid';
import Autocomplete from '@mui/material/Autocomplete';
import IconButton from '@mui/material/IconButton';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemText from '@mui/material/ListItemText';
import DeleteIcon from '@mui/icons-material/Delete';
import AddIcon from '@mui/icons-material/Add';
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
  
  // Estados para ingredientes
  const [ingredientes, setIngredientes] = useState([]);
  const [newIngrediente, setNewIngrediente] = useState('');
  
  // Estados para preparación
  const [preparacion, setPreparacion] = useState('');
  const MAX_PREPARACION_LENGTH = 250;
  
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

  const handleAddIngrediente = () => {
    if (newIngrediente.trim()) {
      setIngredientes([...ingredientes, newIngrediente.trim()]);
      setNewIngrediente('');
    }
  };

  const handleRemoveIngrediente = (index) => {
    setIngredientes(ingredientes.filter((_, i) => i !== index));
  };

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
    if (ingredientes.length === 0) {
      setError('Debes agregar al menos un ingrediente');
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
        ingredientes: ingredientes.map(ing => ({ nombre: ing })),
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
    setIngredientes([]);
    setPreparacion('');
    setNewIngrediente('');
    setError('');
  };

  return (
    <Box>
      {/* Hero Section */}
      <Box sx={{ backgroundColor: '#F6F0E0', py: { xs: 2, sm: 3, md: 4 } }}>
        <Container>
          <Box textAlign="center">
            <Typography 
              variant="h2" 
              sx={{ 
                color: '#6b4f34', 
                fontFamily: 'Lato, sans-serif', 
                fontWeight: 700,
                fontSize: { xs: '1.75rem', sm: '2.5rem', md: '3rem' }
              }}
            >
              Nueva Receta
            </Typography>
            <Typography 
              variant="subtitle1" 
              sx={{ 
                color: '#6b4f34', 
                fontFamily: 'Lato, sans-serif',
                mt: 1,
                fontSize: { xs: '0.9rem', sm: '1rem' }
              }}
            >
              Comparte tu receta con el mundo
            </Typography>
          </Box>
        </Container>
      </Box>

      <Container maxWidth="xl" sx={{ py: { xs: 2, sm: 3, md: 4 }, px: { xs: 2, sm: 3 } }}>
        {error && (
          <Alert 
            severity="error" 
            sx={{ mb: 3 }} 
            onClose={() => setError('')}
          >
            {error}
          </Alert>
        )}

        <Grid container spacing={{ xs: 2, sm: 3 }} justifyContent="center">
          {/* Columna Izquierda - Formulario Principal */}
          <Grid item xs={12} md={9}>
            {/* Información Básica */}
            <Paper elevation={2} sx={{ p: { xs: 2, sm: 3 }, mb: { xs: 2, sm: 3 }, borderRadius: 2 }}>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <ImageIcon sx={{ mr: 1, color: '#F75442', fontSize: { xs: 20, sm: 24 } }} />
                <Typography 
                  variant="h6" 
                  sx={{ 
                    fontFamily: 'Lato, sans-serif', 
                    fontWeight: 600,
                    fontSize: { xs: '1rem', sm: '1.25rem' }
                  }}
                >
                  Información Básica
                </Typography>
              </Box>
              
              <Divider sx={{ mb: { xs: 2, sm: 3 } }} />

              <Grid container spacing={2}>
                <Grid item xs={12}>
                  <TextField
                    fullWidth
                    label="Nombre de la receta"
                    value={nombre}
                    onChange={(e) => setNombre(e.target.value)}
                    required
                    placeholder="Ej: Tacos al Pastor"
                  />
                </Grid>

                <Grid item xs={12}>
                  <TextField
                    fullWidth
                    label="URL de la imagen (opcional)"
                    value={urlImagen}
                    onChange={(e) => setUrlImagen(e.target.value)}
                    placeholder="https://ejemplo.com/imagen.jpg"
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
                          borderRadius: 1,
                          objectFit: 'cover'
                        }}
                        onError={(e) => { e.target.src = 'https://placehold.co/600x360'; }}
                      />
                    </Box>
                  )}
                </Grid>
              </Grid>
            </Paper>

            {/* País y Categoría */}
            <Paper elevation={2} sx={{ p: { xs: 2, sm: 3 }, mb: { xs: 2, sm: 3 }, borderRadius: 2 }}>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <PublicIcon sx={{ mr: 1, color: '#F75442', fontSize: { xs: 20, sm: 24 } }} />
                <Typography 
                  variant="h6" 
                  sx={{ 
                    fontFamily: 'Lato, sans-serif', 
                    fontWeight: 600,
                    fontSize: { xs: '1rem', sm: '1.25rem' }
                  }}
                >
                  Clasificación
                </Typography>
              </Box>
              
              <Divider sx={{ mb: { xs: 2, sm: 3 } }} />

              <Grid container spacing={2}>
                <Grid item xs={12} sm={6}>
                  <Autocomplete
                    options={paises}
                    getOptionLabel={(option) => option.nombre || ''}
                    value={selectedPais}
                    onChange={(event, newValue) => setSelectedPais(newValue)}
                    renderInput={(params) => (
                      <TextField {...params} label="País" required />
                    )}
                    ListboxProps={{
                      style: {
                        maxHeight: '300px',
                      }
                    }}
                    renderOption={(props, option) => (
                      <li {...props} style={{ padding: '10px 16px' }}>
                        <Typography variant="body1">{option.nombre}</Typography>
                      </li>
                    )}
                  />
                </Grid>

                <Grid item xs={12} sm={6}>
                  <Autocomplete
                    options={categorias}
                    getOptionLabel={(option) => option.nombre || ''}
                    value={selectedCategoria}
                    onChange={(event, newValue) => setSelectedCategoria(newValue)}
                    renderInput={(params) => (
                      <TextField {...params} label="Categoría" required />
                    )}
                    ListboxProps={{
                      style: {
                        maxHeight: '300px',
                      }
                    }}
                    renderOption={(props, option) => (
                      <li {...props} style={{ padding: '10px 16px' }}>
                        <Typography variant="body1">{option.nombre}</Typography>
                      </li>
                    )}
                  />
                </Grid>
              </Grid>
            </Paper>

            {/* Ingredientes */}
            <Paper elevation={2} sx={{ p: { xs: 2, sm: 3 }, mb: { xs: 2, sm: 3 }, borderRadius: 2 }}>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2, flexWrap: 'wrap', gap: 1 }}>
                <Box sx={{ display: 'flex', alignItems: 'center', flexGrow: 1 }}>
                  <RestaurantIcon sx={{ mr: 1, color: '#F75442', fontSize: { xs: 20, sm: 24 } }} />
                  <Typography 
                    variant="h6" 
                    sx={{ 
                      fontFamily: 'Lato, sans-serif', 
                      fontWeight: 600,
                      fontSize: { xs: '1rem', sm: '1.25rem' }
                    }}
                  >
                    Ingredientes
                  </Typography>
                </Box>
                <Chip 
                  label={ingredientes.length}
                  size="small"
                />
              </Box>
              
              <Divider sx={{ mb: { xs: 2, sm: 3 } }} />

              <Box sx={{ display: 'flex', flexDirection: { xs: 'column', sm: 'row' }, gap: 1, mb: 2 }}>
                <TextField
                  fullWidth
                  size="small"
                  label="Agregar ingrediente"
                  value={newIngrediente}
                  onChange={(e) => setNewIngrediente(e.target.value)}
                  onKeyPress={(e) => {
                    if (e.key === 'Enter') {
                      e.preventDefault();
                      handleAddIngrediente();
                    }
                  }}
                  placeholder="Ej: 2 tazas de harina"
                />
                <Button 
                  variant="contained" 
                  onClick={handleAddIngrediente}
                  startIcon={<AddIcon />}
                  fullWidth
                  sx={{ 
                    backgroundColor: '#F75442', 
                    '&:hover': { backgroundColor: '#d43f2f' },
                    minWidth: { sm: 'auto' }
                  }}
                >
                  Agregar
                </Button>
              </Box>

              {ingredientes.length > 0 ? (
                <List sx={{ p: 0 }}>
                  {ingredientes.map((ing, index) => (
                    <ListItem
                      key={index}
                      secondaryAction={
                        <IconButton edge="end" onClick={() => handleRemoveIngrediente(index)}>
                          <DeleteIcon />
                        </IconButton>
                      }
                      sx={{ 
                        border: '1px solid #eee', 
                        borderRadius: 1, 
                        mb: 1,
                        px: { xs: 1, sm: 2 }
                      }}
                    >
                      <ListItemText 
                        primary={`${index + 1}. ${ing}`}
                        primaryTypographyProps={{
                          fontSize: { xs: '0.9rem', sm: '1rem' }
                        }}
                      />
                    </ListItem>
                  ))}
                </List>
              ) : (
                <Box sx={{ 
                  textAlign: 'center', 
                  py: { xs: 2, sm: 3 }, 
                  backgroundColor: '#f9f9f9', 
                  borderRadius: 1,
                  border: '1px dashed #ddd'
                }}>
                  <RestaurantIcon sx={{ fontSize: { xs: 32, sm: 40 }, color: '#ddd', mb: 1 }} />
                  <Typography color="text.secondary" variant="body2" sx={{ fontSize: { xs: '0.8rem', sm: '0.875rem' } }}>
                    No hay ingredientes agregados
                  </Typography>
                </Box>
              )}
            </Paper>

            {/* Preparación */}
            <Paper elevation={2} sx={{ p: { xs: 2, sm: 3 }, borderRadius: 2 }}>
              <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                <FormatListNumberedIcon sx={{ mr: 1, color: '#F75442', fontSize: { xs: 20, sm: 24 } }} />
                <Typography 
                  variant="h6" 
                  sx={{ 
                    fontFamily: 'Lato, sans-serif', 
                    fontWeight: 600,
                    fontSize: { xs: '1rem', sm: '1.25rem' }
                  }}
                >
                  Preparación
                </Typography>
              </Box>
              
              <Divider sx={{ mb: { xs: 2, sm: 3 } }} />

              <TextField
                fullWidth
                label="Instrucciones de preparación"
                value={preparacion}
                onChange={(e) => setPreparacion(e.target.value)}
                required
                multiline
                rows={8}
                placeholder="Describe los pasos de preparación..."
                inputProps={{ maxLength: MAX_PREPARACION_LENGTH }}
                helperText={`${preparacion.length}/${MAX_PREPARACION_LENGTH} caracteres`}
              />
            </Paper>
          </Grid>

          {/* Columna Derecha - Resumen */}
          <Grid item xs={12} md={3}>
            <Paper 
              elevation={2} 
              sx={{ 
                p: { xs: 2, sm: 3 }, 
                borderRadius: 2, 
                position: { md: 'sticky' },
                top: { md: 20 },
                backgroundColor: '#F6F0E0'
              }}
            >
              <Typography 
                variant="h6" 
                sx={{ 
                  fontFamily: 'Lato, sans-serif', 
                  fontWeight: 600, 
                  mb: 2, 
                  color: '#6b4f34',
                  fontSize: { xs: '1rem', sm: '1.25rem' }
                }}
              >
                Resumen
              </Typography>
              
              <Divider sx={{ mb: 2 }} />
              
              <Box sx={{ mb: 2 }}>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5, fontSize: { xs: '0.8rem', sm: '0.875rem' } }}>
                  Nombre
                </Typography>
                <Typography variant="body1" sx={{ fontWeight: 500, fontSize: { xs: '0.9rem', sm: '1rem' } }}>
                  {nombre || 'Sin nombre'}
                </Typography>
              </Box>

              <Box sx={{ mb: 2 }}>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5, fontSize: { xs: '0.8rem', sm: '0.875rem' } }}>
                  País
                </Typography>
                <Typography variant="body1" sx={{ fontWeight: 500, fontSize: { xs: '0.9rem', sm: '1rem' } }}>
                  {selectedPais?.nombre || 'No seleccionado'}
                </Typography>
              </Box>

              <Box sx={{ mb: 2 }}>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5, fontSize: { xs: '0.8rem', sm: '0.875rem' } }}>
                  Categoría
                </Typography>
                <Typography variant="body1" sx={{ fontWeight: 500, fontSize: { xs: '0.9rem', sm: '1rem' } }}>
                  {selectedCategoria?.nombre || 'No seleccionada'}
                </Typography>
              </Box>

              <Divider sx={{ my: 2 }} />

              <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
                <Typography variant="body2" color="text.secondary" sx={{ fontSize: { xs: '0.8rem', sm: '0.875rem' } }}>
                  Ingredientes
                </Typography>
                <Chip label={ingredientes.length} size="small" />
              </Box>

              <Box sx={{ mb: 2 }}>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5, fontSize: { xs: '0.8rem', sm: '0.875rem' } }}>
                  Preparación
                </Typography>
                <Typography variant="body2" sx={{ fontSize: { xs: '0.85rem', sm: '0.875rem' } }}>
                  {preparacion.length > 0 ? `${preparacion.length}/${MAX_PREPARACION_LENGTH} caracteres` : 'Sin preparación'}
                </Typography>
              </Box>

              <Divider sx={{ my: 2 }} />

              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1.5 }}>
                <Button 
                  variant="contained"
                  fullWidth
                  size="large"
                  onClick={handleSubmit}
                  disabled={loading}
                  sx={{ 
                    backgroundColor: '#F75442',
                    '&:hover': { 
                      backgroundColor: '#d43f2f'
                    },
                    fontSize: { xs: '0.9rem', sm: '1rem' }
                  }}
                >
                  {loading ? 'Creando...' : 'Crear Receta'}
                </Button>
                
                <Button 
                  variant="outlined"
                  fullWidth
                  onClick={handleReset}
                  disabled={loading}
                  sx={{ fontSize: { xs: '0.9rem', sm: '1rem' } }}
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
        autoHideDuration={6000}
        onClose={() => setSuccess(false)}
        anchorOrigin={{ vertical: 'top', horizontal: 'center' }}
      >
        <Alert severity="success" sx={{ width: '100%' }}>
          Receta creada exitosamente! Redirigiendo...
        </Alert>
      </Snackbar>
    </Box>
  );
}
