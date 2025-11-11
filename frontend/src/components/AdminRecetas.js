import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  IconButton,
  Chip,
  Alert,
  CircularProgress,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  Tabs,
  Tab,
  List,
  ListItem,
  ListItemText,
  Divider,
  ListItemSecondaryAction
} from '@mui/material';
import {
  Edit as EditIcon,
  Delete as DeleteIcon,
  Visibility as VisibilityIcon,
  Comment as CommentIcon,
  Kitchen as KitchenIcon
} from '@mui/icons-material';
import { 
  adminGetRecetas, 
  adminUpdateReceta, 
  adminDeleteReceta, 
  formatFecha,
  getComentariosReceta,
  adminDeleteComentario,
  getUserNombre
} from '../api';

function AdminRecetas() {
  const [recetas, setRecetas] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [openDialog, setOpenDialog] = useState(false);
  const [openViewDialog, setOpenViewDialog] = useState(false);
  const [selectedReceta, setSelectedReceta] = useState(null);
  const [detailTab, setDetailTab] = useState(0);
  const [comentarios, setComentarios] = useState([]);
  const [ingredientes, setIngredientes] = useState([]);
  const [formData, setFormData] = useState({
    nombre: '',
    urlImagen: '',
    preparacion: '',
    estado: 1,
    idCat: '',
    idPais: '',
    idUsr: ''
  });

  const loadRecetas = async () => {
    try {
      setLoading(true);
      const response = await adminGetRecetas();
      setRecetas(response.data || []);
      setError(null);
    } catch (err) {
      setError('Error al cargar recetas: ' + (err.response?.data?.mensaje || err.message));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadRecetas();
  }, []);

  const handleView = (receta) => {
    setSelectedReceta(receta);
    setDetailTab(0);
    loadRecetaDetails(receta.idReceta);
    setOpenViewDialog(true);
  };

  const loadRecetaDetails = async (recetaId) => {
    try {
      // Cargar comentarios
      const commentsRes = await getComentariosReceta(recetaId);
      const comentariosList = commentsRes.data || [];
      
      // Obtener nombres de usuarios para cada comentario
      const comentariosConNombres = await Promise.all(
        comentariosList.map(async (comentario) => {
          // Intentar obtener el ID del usuario de diferentes campos posibles
          const userId = comentario.usuario?.idUsr || comentario.idUsuario || comentario.idUsr || comentario.usuario_id || comentario.userId;
          
          if (!userId) {
            return {
              ...comentario,
              nombreUsuario: 'Usuario'
            };
          }
          
          try {
            const nombreResponse = await getUserNombre(userId);
            return {
              ...comentario,
              nombreUsuario: nombreResponse?.data?.nombre || nombreResponse?.nombre || 'Usuario'
            };
          } catch (error) {
            console.error('Error obteniendo nombre de usuario:', error);
            return {
              ...comentario,
              nombreUsuario: 'Usuario'
            };
          }
        })
      );
      
      setComentarios(comentariosConNombres);

      // Cargar ingredientes de la receta misma
      const recetaData = recetas.find(r => r.idReceta === recetaId);
      if (recetaData?.ingredientes) {
        // Si ingredientes es string, parsearlo
        if (typeof recetaData.ingredientes === 'string') {
          try {
            const parsed = JSON.parse(recetaData.ingredientes);
            setIngredientes(Array.isArray(parsed) ? parsed : []);
          } catch {
            setIngredientes([]);
          }
        } else if (Array.isArray(recetaData.ingredientes)) {
          setIngredientes(recetaData.ingredientes);
        }
      }
    } catch (err) {
      console.error('Error cargando detalles:', err);
    }
  };

  const handleDeleteComentario = async (id) => {
    if (!window.confirm('¿Eliminar este comentario?')) return;
    try {
      const response = await adminDeleteComentario(id);
      
      // Verificar si la respuesta indica fallo
      if (response.data?.exito === false) {
        setError(response.data?.mensaje || 'Error al eliminar comentario');
        setTimeout(() => setError(null), 5000);
        return;
      }
      
      setSuccess('Comentario eliminado');
      loadRecetaDetails(selectedReceta.idReceta);
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      const errorMsg = err.response?.data?.mensaje || 'Error al eliminar comentario';
      setError(errorMsg);
      setTimeout(() => setError(null), 5000);
    }
  };

  const handleEdit = (receta) => {
    setSelectedReceta(receta);
    setFormData({
      nombre: receta.nombre || '',
      urlImagen: receta.urlImagen || '',
      preparacion: receta.preparacion || '',
      estado: receta.estado ?? 1,
      idCat: receta.idCat || '',
      idPais: receta.idPais || '',
      idUsr: receta.idUsr || ''
    });
    setOpenDialog(true);
  };

  const handleDelete = async (id) => {
    if (!window.confirm('¿Estás seguro de eliminar esta receta?')) return;
    
    try {
      const response = await adminDeleteReceta(id);
      
      // Verificar si la respuesta indica éxito
      if (response.data?.exito === false) {
        setError(response.data?.mensaje || 'Error al eliminar receta');
        setTimeout(() => setError(null), 5000);
        return;
      }
      
      setSuccess('Receta eliminada correctamente');
      loadRecetas();
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      const errorMsg = err.response?.data?.mensaje || err.message;
      setError('Error al eliminar receta: ' + errorMsg);
      setTimeout(() => setError(null), 5000);
    }
  };

  const handleSave = async () => {
    if (!selectedReceta) return;
    
    try {
      const response = await adminUpdateReceta(selectedReceta.idReceta, formData);
      
      // Verificar si la respuesta indica éxito
      if (response.data?.exito === false) {
        setError(response.data?.mensaje || 'Error al actualizar receta');
        setTimeout(() => setError(null), 5000);
        return;
      }
      
      setSuccess('Receta actualizada correctamente');
      setOpenDialog(false);
      loadRecetas();
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      const errorMsg = err.response?.data?.mensaje || err.message;
      setError('Error al actualizar receta: ' + errorMsg);
      setTimeout(() => setError(null), 5000);
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: (name === 'estado' || name === 'idCat' || name === 'idPais' || name === 'idUsr') 
        ? parseInt(value) || '' 
        : value
    }));
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box>
      <Typography variant="h5" gutterBottom sx={{ mb: 3, fontWeight: 'bold' }}>
        Gestión de Recetas ({recetas.length})
      </Typography>

      {error && <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError(null)}>{error}</Alert>}
      {success && <Alert severity="success" sx={{ mb: 2 }} onClose={() => setSuccess(null)}>{success}</Alert>}

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow sx={{ backgroundColor: 'primary.main' }}>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>ID</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Nombre</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>País</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Categoría</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Estado</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Visitas</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Fecha</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Acciones</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {recetas.map((receta) => (
              <TableRow key={receta.idReceta} hover>
                <TableCell>{receta.idReceta}</TableCell>
                <TableCell>{receta.nombre}</TableCell>
                <TableCell>{receta.idPais}</TableCell>
                <TableCell>{receta.idCat}</TableCell>
                <TableCell>
                  <Chip 
                    label={receta.estado === 1 ? 'Activo' : 'Inactivo'} 
                    color={receta.estado === 1 ? 'success' : 'default'}
                    size="small"
                  />
                </TableCell>
                <TableCell>{receta.visitas || 0}</TableCell>
                <TableCell>
                  <Typography variant="caption">
                    {formatFecha(receta.fechaCreacion)}
                  </Typography>
                </TableCell>
                <TableCell>
                  <IconButton 
                    size="small" 
                    color="info" 
                    onClick={() => handleView(receta)}
                    title="Ver"
                  >
                    <VisibilityIcon />
                  </IconButton>
                  <IconButton 
                    size="small" 
                    color="primary" 
                    onClick={() => handleEdit(receta)}
                    title="Editar"
                  >
                    <EditIcon />
                  </IconButton>
                  <IconButton 
                    size="small" 
                    color="error" 
                    onClick={() => handleDelete(receta.idReceta)}
                    title="Eliminar"
                  >
                    <DeleteIcon />
                  </IconButton>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Dialog para ver detalles */}
      <Dialog open={openViewDialog} onClose={() => setOpenViewDialog(false)} maxWidth="lg" fullWidth>
        <DialogTitle>
          {selectedReceta?.nombre}
          <Typography variant="caption" display="block" color="text.secondary">
            ID: {selectedReceta?.idReceta}
          </Typography>
        </DialogTitle>
        <DialogContent>
          {selectedReceta && (
            <Box>
              <Tabs value={detailTab} onChange={(e, v) => setDetailTab(v)} sx={{ borderBottom: 1, borderColor: 'divider' }}>
                <Tab icon={<VisibilityIcon />} label="Información" />
                <Tab icon={<KitchenIcon />} label={`Ingredientes (${ingredientes.length})`} />
                <Tab icon={<CommentIcon />} label={`Comentarios (${comentarios.length})`} />
              </Tabs>

              {/* Tab 0: Información */}
              {detailTab === 0 && (
                <Box sx={{ mt: 3 }}>
                  {selectedReceta.urlImagen && (
                    <Box sx={{ textAlign: 'center', mb: 2 }}>
                      <img 
                        src={selectedReceta.urlImagen} 
                        alt={selectedReceta.nombre}
                        style={{ maxWidth: '100%', maxHeight: '300px', borderRadius: '8px' }}
                      />
                    </Box>
                  )}
                  <Typography><strong>Preparación:</strong></Typography>
                  <Typography sx={{ whiteSpace: 'pre-wrap', mb: 2 }}>{selectedReceta.preparacion}</Typography>
                  <Divider sx={{ my: 2 }} />
                  <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
                    <Chip label={`Estado: ${selectedReceta.estado === 1 ? 'Activo' : 'Inactivo'}`} color={selectedReceta.estado === 1 ? 'success' : 'default'} />
                    <Chip label={`País ID: ${selectedReceta.idPais}`} />
                    <Chip label={`Categoría ID: ${selectedReceta.idCat}`} />
                    <Chip label={`Visitas: ${selectedReceta.visitas || 0}`} />
                    <Chip label={`Usuario ID: ${selectedReceta.idUsr}`} />
                    <Chip label={`Fecha: ${formatFecha(selectedReceta.fechaCreacion)}`} />
                  </Box>
                </Box>
              )}

              {/* Tab 1: Ingredientes */}
              {detailTab === 1 && (
                <Box sx={{ mt: 3 }}>
                  {ingredientes.length > 0 ? (
                    <List>
                      {ingredientes.map((ing, idx) => (
                        <ListItem key={ing.idIngrediente || idx}>
                          <ListItemText 
                            primary={`ID: ${ing.idIngrediente}`}
                            secondary={
                              <Typography 
                                component="span" 
                                variant="body2" 
                                sx={{ whiteSpace: 'pre-wrap', display: 'block', mt: 1 }}
                              >
                                {ing.nombre}
                              </Typography>
                            }
                          />
                        </ListItem>
                      ))}
                    </List>
                  ) : (
                    <Typography color="text.secondary" sx={{ textAlign: 'center', py: 3 }}>
                      No hay ingredientes registrados
                    </Typography>
                  )}
                </Box>
              )}

              {/* Tab 2: Comentarios */}
              {detailTab === 2 && (
                <Box sx={{ mt: 3 }}>
                  {comentarios.length > 0 ? (
                    <List>
                      {comentarios.map((com) => (
                        <React.Fragment key={com.idComentario}>
                          <ListItem alignItems="flex-start">
                            <ListItemText 
                              primary={
                                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                  <Typography variant="subtitle2">
                                    {com.nombreUsuario || 'Usuario'}
                                  </Typography>
                                  <Typography variant="caption" color="text.secondary">
                                    {formatFecha(com.fechaCreacion)}
                                  </Typography>
                                </Box>
                              }
                              secondary={com.texto}
                            />
                            <ListItemSecondaryAction>
                              <IconButton edge="end" size="small" color="error" onClick={() => handleDeleteComentario(com.idComentario)}>
                                <DeleteIcon />
                              </IconButton>
                            </ListItemSecondaryAction>
                          </ListItem>
                          <Divider />
                        </React.Fragment>
                      ))}
                    </List>
                  ) : (
                    <Typography color="text.secondary" sx={{ textAlign: 'center', py: 3 }}>
                      No hay comentarios
                    </Typography>
                  )}
                </Box>
              )}
            </Box>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenViewDialog(false)}>Cerrar</Button>
        </DialogActions>
      </Dialog>

      {/* Dialog para editar */}
      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} maxWidth="md" fullWidth>
        <DialogTitle>
          Editar Receta
          {selectedReceta && (
            <Typography variant="caption" display="block" color="text.secondary">
              ID: {selectedReceta.idReceta} | Creado: {formatFecha(selectedReceta.fechaCreacion)}
            </Typography>
          )}
        </DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, mt: 2 }}>
            <TextField
              label="Nombre"
              name="nombre"
              value={formData.nombre}
              onChange={handleChange}
              fullWidth
            />
            <TextField
              label="URL de Imagen"
              name="urlImagen"
              value={formData.urlImagen}
              onChange={handleChange}
              fullWidth
              placeholder="https://..."
            />
            <TextField
              label="Preparación"
              name="preparacion"
              value={formData.preparacion}
              onChange={handleChange}
              fullWidth
              multiline
              rows={6}
            />
            <Box sx={{ display: 'flex', gap: 2 }}>
              <TextField
                select
                label="Estado"
                name="estado"
                value={formData.estado}
                onChange={handleChange}
                fullWidth
                SelectProps={{ native: true }}
              >
                <option value={1}>Activo</option>
                <option value={0}>Inactivo</option>
              </TextField>
              <TextField
                label="ID Categoría"
                name="idCat"
                value={formData.idCat}
                onChange={handleChange}
                fullWidth
                type="number"
              />
            </Box>
            <Box sx={{ display: 'flex', gap: 2 }}>
              <TextField
                label="ID País"
                name="idPais"
                value={formData.idPais}
                onChange={handleChange}
                fullWidth
                type="number"
              />
              <TextField
                label="ID Usuario"
                name="idUsr"
                value={formData.idUsr}
                onChange={handleChange}
                fullWidth
                type="number"
              />
            </Box>
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenDialog(false)}>Cancelar</Button>
          <Button onClick={handleSave} variant="contained" color="primary">
            Guardar
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}

export default AdminRecetas;
