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
  ListItemSecondaryAction,
  Rating,
  TablePagination,
  Select,
  MenuItem,
  FormControl,
  InputLabel
} from '@mui/material';
import {
  Edit as EditIcon,
  Delete as DeleteIcon,
  Visibility as VisibilityIcon,
  Comment as CommentIcon,
  Kitchen as KitchenIcon,
  ThumbUp as ThumbUpIcon,
  Star as StarIcon
} from '@mui/icons-material';
import SearchFilter from './SearchFilter';
import { 
  adminGetRecetas, 
  adminUpdateReceta, 
  adminDeleteReceta, 
  formatFecha,
  getComentariosReceta,
  adminDeleteComentario,
  getUserNombre,
  getEstrellaStats,
  getMeGustaCount,
  adminGetMeGustasByReceta,
  adminDeleteMeGusta,
  adminGetEstrellasByReceta,
  adminDeleteEstrella,
  adminGetPaises,
  adminGetCategorias
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
  const [recetasStats, setRecetasStats] = useState({});
  const [likes, setLikes] = useState([]);
  const [calificaciones, setCalificaciones] = useState([]);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterPais, setFilterPais] = useState('');
  const [filterCategoria, setFilterCategoria] = useState('');
  const [filterEstado, setFilterEstado] = useState('');
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
      
      // Cargar recetas, países y categorías en paralelo
      const [recetasResponse, paisesResponse, categoriasResponse] = await Promise.all([
        adminGetRecetas(),
        adminGetPaises(),
        adminGetCategorias()
      ]);
      
      const recetasList = recetasResponse.data || [];
      const paisesList = paisesResponse.data || [];
      const categoriasList = categoriasResponse.data || [];
      
      // Crear mapas para búsqueda rápida
      const paisesMap = {};
      paisesList.forEach(pais => {
        paisesMap[pais.idPais] = pais;
      });
      
      const categoriasMap = {};
      categoriasList.forEach(categoria => {
        categoriasMap[categoria.idCat] = categoria;
      });
      
      // Enriquecer recetas con datos de país y categoría
      const recetasEnriquecidas = recetasList.map(receta => ({
        ...receta,
        pais: paisesMap[receta.idPais] || null,
        categoria: categoriasMap[receta.idCat] || null
      }));
      
      console.log('Recetas enriquecidas:', recetasEnriquecidas);
      console.log('Primera receta enriquecida:', recetasEnriquecidas[0]);
      
      setRecetas(recetasEnriquecidas);
      
      // Cargar estadísticas para todas las recetas
      const statsPromises = recetasEnriquecidas.map(async (receta) => {
        try {
          const [estrellasRes, likesRes] = await Promise.all([
            getEstrellaStats(receta.idReceta).catch((err) => {
              console.error(`Error obteniendo estrellas para receta ${receta.idReceta}:`, err);
              return { data: { promedio: 0, total: 0, avgStars: 0, totalStars: 0 } };
            }),
            getMeGustaCount(receta.idReceta).catch(() => ({ data: { count: 0 } }))
          ]);
          
          console.log(`Stats para receta ${receta.idReceta}:`, { estrellasRes: estrellasRes.data, likesRes: likesRes.data });
          
          return {
            idReceta: receta.idReceta,
            avgStars: estrellasRes.data?.promedio || estrellasRes.data?.avgStars || 0,
            totalStars: estrellasRes.data?.total || estrellasRes.data?.totalStars || 0,
            likesCount: likesRes.data?.count || 0
          };
        } catch {
          return {
            idReceta: receta.idReceta,
            avgStars: 0,
            totalStars: 0,
            likesCount: 0
          };
        }
      });
      
      const stats = await Promise.all(statsPromises);
      const statsMap = {};
      stats.forEach(stat => {
        statsMap[stat.idReceta] = stat;
      });
      setRecetasStats(statsMap);
      
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

      // Cargar likes de la receta usando endpoint específico por receta
      try {
        const likesRes = await adminGetMeGustasByReceta(recetaId);
        const likesReceta = likesRes.data || [];
        const likesConNombres = likesReceta.map(like => ({
          ...like,
          idUsuario: like.usuario?.idUsr,
          nombreUsuario: like.usuario?.nombre || 'Usuario'
        }));
        setLikes(likesConNombres);
      } catch (err) {
        console.error('Error cargando likes:', err);
        setLikes([]);
      }

      // Cargar calificaciones de la receta usando endpoint específico por receta
      try {
        const estrellasRes = await adminGetEstrellasByReceta(recetaId);
        const estrellasReceta = estrellasRes.data || [];
        const estrellasConNombres = estrellasReceta.map(estrella => ({
          ...estrella,
          idUsuario: estrella.usuario?.idUsr,
          nombreUsuario: estrella.usuario?.nombre || 'Usuario',
          // Normalizar el campo de calificación (puede ser 'valor', 'estrellas' o 'calificacion')
          valorEstrellas: estrella.valor || estrella.estrellas || estrella.calificacion || 0
        }));
        setCalificaciones(estrellasConNombres);
      } catch (err) {
        console.error('Error cargando calificaciones:', err);
        setCalificaciones([]);
      }

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

  const handleDeleteLike = async (id) => {
    if (!window.confirm('¿Eliminar este like?')) return;
    try {
      const response = await adminDeleteMeGusta(id);
      
      if (response.data?.exito === false) {
        setError(response.data?.mensaje || 'Error al eliminar like');
        setTimeout(() => setError(null), 5000);
        return;
      }
      
      setSuccess('Like eliminado');
      // Recargar detalles de la receta para actualizar los likes
      loadRecetaDetails(selectedReceta.idReceta);
      
      // Actualizar solo las estadísticas de esta receta específica
      try {
        const likesRes = await getMeGustaCount(selectedReceta.idReceta);
        setRecetasStats(prev => ({
          ...prev,
          [selectedReceta.idReceta]: {
            ...prev[selectedReceta.idReceta],
            likesCount: likesRes.data?.count || 0
          }
        }));
      } catch (err) {
        console.error('Error actualizando estadísticas de likes:', err);
      }
      
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      const errorMsg = err.response?.data?.mensaje || 'Error al eliminar like';
      setError(errorMsg);
      setTimeout(() => setError(null), 5000);
    }
  };

  const handleDeleteCalificacion = async (id) => {
    if (!window.confirm('¿Eliminar esta calificación?')) return;
    try {
      const response = await adminDeleteEstrella(id);
      
      if (response.data?.exito === false) {
        setError(response.data?.mensaje || 'Error al eliminar calificación');
        setTimeout(() => setError(null), 5000);
        return;
      }
      
      setSuccess('Calificación eliminada');
      // Recargar detalles de la receta para actualizar las calificaciones
      loadRecetaDetails(selectedReceta.idReceta);
      
      // Actualizar solo las estadísticas de esta receta específica
      try {
        const estrellasRes = await getEstrellaStats(selectedReceta.idReceta);
        setRecetasStats(prev => ({
          ...prev,
          [selectedReceta.idReceta]: {
            ...prev[selectedReceta.idReceta],
            avgStars: estrellasRes.data?.promedio || estrellasRes.data?.avgStars || 0,
            totalStars: estrellasRes.data?.total || estrellasRes.data?.totalStars || 0
          }
        }));
      } catch (err) {
        console.error('Error actualizando estadísticas de estrellas:', err);
      }
      
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      const errorMsg = err.response?.data?.mensaje || 'Error al eliminar calificación';
      setError(errorMsg);
      setTimeout(() => setError(null), 5000);
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
        ? (value === '' ? '' : parseInt(value))
        : value
    }));
  };

  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  // Filtrar recetas según búsqueda y filtros
  const filteredRecetas = recetas.filter(receta => {
    const matchesSearch = searchTerm === '' || 
      receta.nombre?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      receta.idReceta?.toString().includes(searchTerm);
    
    const matchesPais = filterPais === '' || receta.pais?.nombre === filterPais;
    const matchesCategoria = filterCategoria === '' || receta.categoria?.nombre === filterCategoria;
    const matchesEstado = filterEstado === '' || receta.estado === parseInt(filterEstado);
    
    return matchesSearch && matchesPais && matchesCategoria && matchesEstado;
  });

  // Calcular recetas paginadas
  const paginatedRecetas = filteredRecetas.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage);

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
        Gestión de Recetas ({filteredRecetas.length})
      </Typography>

      {error && <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError(null)}>{error}</Alert>}
      {success && <Alert severity="success" sx={{ mb: 2 }} onClose={() => setSuccess(null)}>{success}</Alert>}

      <SearchFilter
        searchValue={searchTerm}
        onSearchChange={(e) => setSearchTerm(e.target.value)}
        searchPlaceholder="Buscar por nombre o ID..."
        showFilter={false}
      />

      <Box sx={{ display: 'flex', gap: 2, mb: 3, mt: 2, flexWrap: 'wrap' }}>
        <FormControl sx={{ minWidth: 200 }}>
          <InputLabel>País</InputLabel>
          <Select
            value={filterPais}
            onChange={(e) => setFilterPais(e.target.value)}
            label="País"
          >
            <MenuItem value="">Todos</MenuItem>
            {[...new Set(recetas.map(r => r.pais?.nombre).filter(Boolean))].map(nombre => (
              <MenuItem key={nombre} value={nombre}>{nombre}</MenuItem>
            ))}
          </Select>
        </FormControl>
        
        <FormControl sx={{ minWidth: 200 }}>
          <InputLabel>Categoría</InputLabel>
          <Select
            value={filterCategoria}
            onChange={(e) => setFilterCategoria(e.target.value)}
            label="Categoría"
          >
            <MenuItem value="">Todas</MenuItem>
            {[...new Set(recetas.map(r => r.categoria?.nombre).filter(Boolean))].map(nombre => (
              <MenuItem key={nombre} value={nombre}>{nombre}</MenuItem>
            ))}
          </Select>
        </FormControl>
        
        <FormControl sx={{ minWidth: 200 }}>
          <InputLabel>Estado</InputLabel>
          <Select
            value={filterEstado}
            onChange={(e) => setFilterEstado(e.target.value)}
            label="Estado"
          >
            <MenuItem value="">Todos</MenuItem>
            <MenuItem value="1">Activa</MenuItem>
            <MenuItem value="0">Inactiva</MenuItem>
          </Select>
        </FormControl>
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow sx={{ backgroundColor: 'primary.main' }}>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>ID</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Nombre</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>País</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Categoría</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Estado</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Likes</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Estrellas</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Fecha</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Acciones</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {paginatedRecetas.map((receta) => (
              <TableRow key={receta.idReceta} hover>
                <TableCell>{receta.idReceta}</TableCell>
                <TableCell>{receta.nombre}</TableCell>
                <TableCell>{receta.pais?.nombre || 'N/A'}</TableCell>
                <TableCell>{receta.categoria?.nombre || 'N/A'}</TableCell>
                <TableCell>
                  <Chip 
                    label={receta.estado === 1 ? 'Activo' : 'Inactivo'} 
                    color={receta.estado === 1 ? 'success' : 'default'}
                    size="small"
                  />
                </TableCell>
                <TableCell>
                  <Chip 
                    label={recetasStats[receta.idReceta]?.likesCount || 0}
                    color="primary"
                    size="small"
                    variant="outlined"
                  />
                </TableCell>
                <TableCell>
                  <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.5 }}>
                    <Typography variant="caption" sx={{ fontWeight: 'bold' }}>
                      ⭐ {recetasStats[receta.idReceta]?.avgStars?.toFixed(1) || '0.0'}
                    </Typography>
                    <Typography variant="caption" color="text.secondary">
                      ({recetasStats[receta.idReceta]?.totalStars || 0} votos)
                    </Typography>
                  </Box>
                </TableCell>
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
        <TablePagination
          component="div"
          count={recetas.length}
          page={page}
          onPageChange={handleChangePage}
          rowsPerPage={rowsPerPage}
          onRowsPerPageChange={handleChangeRowsPerPage}
          rowsPerPageOptions={[5, 10, 25, 50]}
          labelRowsPerPage="Filas por página:"
          labelDisplayedRows={({ from, to, count }) => `${from}-${to} de ${count}`}
        />
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
              <Tabs value={detailTab} onChange={(e, v) => setDetailTab(v)} sx={{ borderBottom: 1, borderColor: 'divider' }} variant="scrollable" scrollButtons="auto">
                <Tab icon={<VisibilityIcon />} label="Información" />
                <Tab icon={<KitchenIcon />} label={`Ingredientes (${ingredientes.length})`} />
                <Tab icon={<CommentIcon />} label={`Comentarios (${comentarios.length})`} />
                <Tab icon={<ThumbUpIcon />} label={`Likes (${likes.length})`} />
                <Tab icon={<StarIcon />} label={`Calificaciones (${calificaciones.length})`} />
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
                    <Chip label={`Likes: ${recetasStats[selectedReceta.idReceta]?.likesCount || 0}`} color="primary" variant="outlined" />
                    <Chip label={`⭐ ${recetasStats[selectedReceta.idReceta]?.avgStars?.toFixed(1) || '0.0'} (${recetasStats[selectedReceta.idReceta]?.totalStars || 0} votos)`} color="warning" variant="outlined" />
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

              {/* Tab 3: Likes */}
              {detailTab === 3 && (
                <Box sx={{ mt: 3 }}>
                  {likes.length > 0 ? (
                    <List>
                      {likes.map((like) => (
                        <React.Fragment key={like.idMeGusta}>
                          <ListItem alignItems="flex-start">
                            <ListItemText 
                              primary={
                                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                    <ThumbUpIcon color="primary" fontSize="small" />
                                    <Typography variant="subtitle2">
                                      {like.nombreUsuario || like.usuario?.nombre || 'Usuario'}
                                    </Typography>
                                    <Chip label={`ID Usuario: ${like.idUsuario || like.usuario?.idUsr}`} size="small" variant="outlined" />
                                  </Box>
                                  <Typography variant="caption" color="text.secondary">
                                    {formatFecha(like.fechaCreacion)}
                                  </Typography>
                                </Box>
                              }
                              secondary={
                                <Typography variant="caption" color="text.secondary">
                                  ID Like: {like.idMeGusta}
                                </Typography>
                              }
                            />
                            <ListItemSecondaryAction>
                              <IconButton edge="end" size="small" color="error" onClick={() => handleDeleteLike(like.idMeGusta)}>
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
                      No hay likes
                    </Typography>
                  )}
                </Box>
              )}

              {/* Tab 4: Calificaciones */}
              {detailTab === 4 && (
                <Box sx={{ mt: 3 }}>
                  {calificaciones.length > 0 ? (
                    <List>
                      {calificaciones.map((cal) => (
                        <React.Fragment key={cal.idEstrella}>
                          <ListItem alignItems="flex-start">
                            <ListItemText 
                              primary={
                                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                    <Typography variant="subtitle2">
                                      {cal.nombreUsuario || cal.usuario?.nombre || 'Usuario'}
                                    </Typography>
                                    <Chip label={`ID Usuario: ${cal.idUsuario || cal.usuario?.idUsr}`} size="small" variant="outlined" />
                                  </Box>
                                  <Typography variant="caption" color="text.secondary">
                                    {formatFecha(cal.fechaCreacion)}
                                  </Typography>
                                </Box>
                              }
                              secondary={
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mt: 1 }}>
                                  <Rating value={cal.valorEstrellas || cal.valor || cal.estrellas || cal.calificacion || 0} readOnly size="small" />
                                  <Typography variant="caption" sx={{ fontWeight: 'bold' }}>
                                    ({cal.valorEstrellas || cal.valor || cal.estrellas || cal.calificacion || 0} / 5)
                                  </Typography>
                                  <Typography variant="caption" color="text.secondary">
                                    · ID: {cal.idEstrella}
                                  </Typography>
                                </Box>
                              }
                            />
                            <ListItemSecondaryAction>
                              <IconButton edge="end" size="small" color="error" onClick={() => handleDeleteCalificacion(cal.idEstrella)}>
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
                      No hay calificaciones
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
                InputLabelProps={{ shrink: true }}
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
