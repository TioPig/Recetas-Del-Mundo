import React, { useEffect, useState } from 'react';
import Container from '@mui/material/Container';
import Box from '@mui/material/Box';
import Grid from '@mui/material/Grid';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import IconButton from '@mui/material/IconButton';
import Dialog from '@mui/material/Dialog';
import DialogTitle from '@mui/material/DialogTitle';
import DialogContent from '@mui/material/DialogContent';
import DialogActions from '@mui/material/DialogActions';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemText from '@mui/material/ListItemText';
import Pagination from '@mui/material/Pagination';
import TextField from '@mui/material/TextField';
import Divider from '@mui/material/Divider';
import Stack from '@mui/material/Stack';
import Snackbar from '@mui/material/Snackbar';
import Alert from '@mui/material/Alert';
import BookmarkIcon from '@mui/icons-material/Bookmark';
import BookmarkBorderIcon from '@mui/icons-material/BookmarkBorder';
import StarIcon from '@mui/icons-material/Star';
import StarBorderIcon from '@mui/icons-material/StarBorder';
import ThumbUpIcon from '@mui/icons-material/ThumbUp';
import ThumbUpOutlinedIcon from '@mui/icons-material/ThumbUpOutlined';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import AddIcon from '@mui/icons-material/Add';
import Drawer from '@mui/material/Drawer';
import Autocomplete from '@mui/material/Autocomplete';
import FilterListIcon from '@mui/icons-material/FilterList';
import CloseIcon from '@mui/icons-material/Close';
import MenuItem from '@mui/material/MenuItem';
import Select from '@mui/material/Select';
import FormControl from '@mui/material/FormControl';
import InputLabel from '@mui/material/InputLabel';
import { getRecetas, putReceta, postLikeReceta, deleteLikeReceta, postStarReceta, deleteStarReceta, postFavoritoReceta, deleteFavoritoReceta, getComentariosReceta, postComentarioReceta, isAuthenticated, getEstrellaStats, getMeGustaCount, getFavoritos, getMeGustas, getEstrellas, getPaises, getCategorias, formatFecha, getUserNombre } from '../api';
import AuthPromptDialog from './AuthPromptDialog';
import RatingDialog from './RatingDialog';
import { useTheme } from '@mui/material/styles';

export default function UserRecetas(){
  const theme = useTheme();
  const [recetas, setRecetas] = useState([]);
  const [mine, setMine] = useState([]);
  const [loading, setLoading] = useState(true);
  const [authPromptOpen, setAuthPromptOpen] = useState(false);
  
  // Modal de receta seleccionada
  const [selectedReceta, setSelectedReceta] = useState(null);
  const [openReceta, setOpenReceta] = useState(false);
  const [comentarios, setComentarios] = useState([]);
  const [newComentario, setNewComentario] = useState('');
  
  // Modal de edición
  const [editDialogOpen, setEditDialogOpen] = useState(false);
  const [editFormData, setEditFormData] = useState({
    nombre: '',
    urlImagen: '',
    preparacion: '',
    ingredientes: []
  });
  
  // Interacciones del usuario
  const [userInteractions, setUserInteractions] = useState({
    favoritos: new Map(),
    likes: new Map(),
    estrellas: new Map()
  });
  
  // Estadísticas del modal
  const [modalStats, setModalStats] = useState({ meGustas: 0, estrellas: { promedio: 0, total: 0 } });
  
  // Rating dialog
  const [ratingDialogOpen, setRatingDialogOpen] = useState(false);
  const [ratingRecetaId, setRatingRecetaId] = useState(null);
  const [ratingRecetaNombre, setRatingRecetaNombre] = useState('');
  
  // Snackbar para notificaciones
  const [snackbar, setSnackbar] = useState({
    open: false,
    message: '',
    severity: 'success' // 'success' | 'error' | 'warning' | 'info'
  });
  
  // Estados para filtros
  const [filterDrawerOpen, setFilterDrawerOpen] = useState(false);
  const [paises, setPaises] = useState([]);
  const [categorias, setCategorias] = useState([]);
  const [selectedPais, setSelectedPais] = useState(null);
  const [selectedCategoria, setSelectedCategoria] = useState(null);
  const [searchNombre, setSearchNombre] = useState('');
  const [sortByStars, setSortByStars] = useState(''); // '', 'asc', 'desc'
  const [recetasWithStars, setRecetasWithStars] = useState(new Map());
  const [fechaDesde, setFechaDesde] = useState('');
  const [fechaHasta, setFechaHasta] = useState('');
  
  // Estados temporales para filtros (solo en el drawer)
  const [tempSelectedPais, setTempSelectedPais] = useState(null);
  const [tempSelectedCategoria, setTempSelectedCategoria] = useState(null);
  const [tempSearchNombre, setTempSearchNombre] = useState('');
  const [tempSortByStars, setTempSortByStars] = useState('');
  const [tempFechaDesde, setTempFechaDesde] = useState('');
  const [tempFechaHasta, setTempFechaHasta] = useState('');
  
  // Paginación
  const [page, setPage] = useState(1);
  const rows = 12;

  useEffect(()=>{
    loadRecetas();
    loadUserInteractions();
  },[]);

  // Cargar países y categorías para los filtros
  useEffect(() => {
    Promise.all([
      getPaises().catch(() => ({ data: [] })),
      getCategorias().catch(() => ({ data: [] }))
    ]).then(([paisesRes, categoriasRes]) => {
      setPaises(paisesRes?.data || []);
      setCategorias(categoriasRes?.data || []);
    });
  }, []);

  // Cargar estadísticas de estrellas cuando se activa el ordenamiento
  useEffect(() => {
    if(sortByStars && mine.length > 0) {
      loadAllRecetasStars(mine);
    }
  }, [sortByStars, mine.length]);

  // Función para cargar estadísticas de estrellas de todas las recetas
  const loadAllRecetasStars = async (recetasList) => {
    try {
      const starsMap = new Map();
      const promises = recetasList.map(async (receta) => {
        const recetaId = receta.idReceta || receta.id;
        try {
          const res = await getEstrellaStats(recetaId);
          const data = res?.data || res;
          const promedio = data?.promedio || data?.average || data?.avg || 0;
          starsMap.set(recetaId, promedio);
        } catch {
          starsMap.set(recetaId, 0);
        }
      });
      await Promise.all(promises);
      setRecetasWithStars(starsMap);
    } catch (e) {
      console.error('Error cargando estadísticas de estrellas:', e);
    }
  };

  const loadRecetas = async () => {
    setLoading(true);
    try{
      const r = await getRecetas();
      const data = r && r.data ? r.data : r;
      const list = Array.isArray(data) ? data : (data?.recetas || data?.items || []);
      setRecetas(list);
      
      let uid = null;
      try{ 
        const u = JSON.parse(localStorage.getItem('user') || 'null'); 
        uid = u && (u.id_usr || u.idUsr || u.id || u._id || u.idUsuario);
      }catch(e){}
      
      const mineList = list.filter(item => {
        if(!uid) return false;
        return (item.idUsr && String(item.idUsr) === String(uid)) || 
               (item.autorId && String(item.autorId) === String(uid)) || 
               (item.idUsuario && String(item.idUsuario) === String(uid)) || 
               (item.createdBy && String(item.createdBy) === String(uid));
      });
      setMine(mineList);
    }catch(e){
      setRecetas([]);
      setMine([]);
    }finally{
      setLoading(false);
    }
  };

  const loadUserInteractions = async () => {
    if(!isAuthenticated()) return;
    try{
      const [favRes, likesRes, estrellasRes] = await Promise.all([
        getFavoritos().catch(()=>null),
        getMeGustas().catch(()=>null),
        getEstrellas().catch(()=>null)
      ]);
      
      const favoritos = new Map();
      const favData = favRes?.data || favRes || [];
      (Array.isArray(favData) ? favData : []).forEach(f => {
        const recetaId = f.receta?.idReceta || f.receta?.id || f.idReceta;
        if(recetaId) favoritos.set(recetaId, true);
      });
      
      const likes = new Map();
      const likesData = likesRes?.data || likesRes || [];
      (Array.isArray(likesData) ? likesData : []).forEach(l => {
        const recetaId = l.receta?.idReceta || l.receta?.id || l.idReceta;
        if(recetaId) likes.set(recetaId, true);
      });
      
      const estrellas = new Map();
      const estrellasData = estrellasRes?.data || estrellasRes || [];
      (Array.isArray(estrellasData) ? estrellasData : []).forEach(e => {
        const recetaId = e.receta?.idReceta || e.receta?.id || e.idReceta;
        if(recetaId) estrellas.set(recetaId, e.estrellas || 5);
      });
      
      setUserInteractions({ favoritos, likes, estrellas });
    }catch(e){}
  };

  const handleLike = async (recetaId) => {
    if(!isAuthenticated()){ setAuthPromptOpen(true); return; }
    try{
      const hasLike = userInteractions.likes.get(recetaId);
      if(hasLike){
        await deleteLikeReceta(recetaId);
        setUserInteractions(prev => {
          const newLikes = new Map(prev.likes);
          newLikes.delete(recetaId);
          return { ...prev, likes: newLikes };
        });
      }else{
        await postLikeReceta(recetaId);
        setUserInteractions(prev => {
          const newLikes = new Map(prev.likes);
          newLikes.set(recetaId, true);
          return { ...prev, likes: newLikes };
        });
      }
      if(openReceta && (selectedReceta?.idReceta === recetaId || selectedReceta?.id === recetaId)) {
        loadModalStats(recetaId);
      }
    }catch(e){}
  };

  const handleFavorite = async (recetaId) => {
    if(!isAuthenticated()){ setAuthPromptOpen(true); return; }
    try{
      const hasFav = userInteractions.favoritos.get(recetaId);
      if(hasFav){
        await deleteFavoritoReceta(recetaId);
        setUserInteractions(prev => {
          const newFavs = new Map(prev.favoritos);
          newFavs.delete(recetaId);
          return { ...prev, favoritos: newFavs };
        });
      }else{
        await postFavoritoReceta(recetaId);
        setUserInteractions(prev => {
          const newFavs = new Map(prev.favoritos);
          newFavs.set(recetaId, true);
          return { ...prev, favoritos: newFavs };
        });
      }
    }catch(e){}
  };

  const handleOpenRating = (recetaId, recetaNombre) => {
    if(!isAuthenticated()){ setAuthPromptOpen(true); return; }
    setRatingRecetaId(recetaId);
    setRatingRecetaNombre(recetaNombre);
    setRatingDialogOpen(true);
  };

  const handleRate = async (valorEstrellas) => {
    if(!ratingRecetaId) return;
    try{
      await postStarReceta(ratingRecetaId, valorEstrellas);
      setUserInteractions(prev => {
        const newEstrellas = new Map(prev.estrellas);
        newEstrellas.set(ratingRecetaId, valorEstrellas);
        return { ...prev, estrellas: newEstrellas };
      });
      if(openReceta && (selectedReceta?.idReceta === ratingRecetaId || selectedReceta?.id === ratingRecetaId)) {
        loadModalStats(ratingRecetaId);
      }
    }catch(e){ console.error('Error al calificar:', e); }
  };

  const handleDeleteRating = async () => {
    if(!ratingRecetaId) return;
    try{
      const estrellaActual = userInteractions.estrellas.get(ratingRecetaId);
      if(estrellaActual) {
        const estrellasRes = await getEstrellas();
        const estrellasData = estrellasRes?.data || estrellasRes || [];
        const miEstrella = estrellasData.find(e => 
          (e.receta?.idReceta === ratingRecetaId || e.receta?.id === ratingRecetaId)
        );
        
        if(miEstrella && miEstrella.idEstrella) {
          await deleteStarReceta(miEstrella.idEstrella);
          setUserInteractions(prev => {
            const newEstrellas = new Map(prev.estrellas);
            newEstrellas.delete(ratingRecetaId);
            return { ...prev, estrellas: newEstrellas };
          });
          if(openReceta && (selectedReceta?.idReceta === ratingRecetaId || selectedReceta?.id === ratingRecetaId)) {
            loadModalStats(ratingRecetaId);
          }
        }
      }
    }catch(e){ console.error('Error al eliminar calificación:', e); }
  };

  const loadComentarios = async (recetaId) => {
    if(!recetaId) return setComentarios([]);
    try{
      const r = await getComentariosReceta(recetaId);
      const data = r && r.data ? r.data : r;
      const list = Array.isArray(data) ? data : (Array.isArray(data?.comentarios) ? data.comentarios : (Array.isArray(data?.items) ? data.items : []));
      
      // Obtener nombres de usuarios para cada comentario
      const comentariosConNombres = await Promise.all(
        list.map(async (comentario) => {
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
    }catch(e){ setComentarios([]); }
  };

  const loadModalStats = async (recetaId) => {
    if(!recetaId) return;
    try {
      const [meGustaRes, estrellasRes] = await Promise.all([
        getMeGustaCount(recetaId).catch(() => null),
        getEstrellaStats(recetaId).catch(() => null)
      ]);
      
      const meGustas = meGustaRes?.data?.count || meGustaRes?.count || 0;
      const estrellasData = estrellasRes?.data || estrellasRes || {};
      const estrellas = {
        promedio: estrellasData.promedio || estrellasData.average || 0,
        total: estrellasData.total || estrellasData.count || 0
      };
      
      setModalStats({ meGustas, estrellas });
    } catch(e) {
      setModalStats({ meGustas: 0, estrellas: { promedio: 0, total: 0 } });
    }
  };

  const handleOpenReceta = async (receta) => {
    setSelectedReceta(receta);
    const recetaId = receta?.idReceta || receta?.id;
    Promise.all([
      loadComentarios(recetaId),
      loadModalStats(recetaId)
    ]);
    setOpenReceta(true);
  };

  const handleCloseReceta = () => {
    setOpenReceta(false);
    setSelectedReceta(null);
    setComentarios([]);
    setNewComentario('');
    setModalStats({ meGustas: 0, estrellas: { promedio: 0, total: 0 } });
  };

  const handleEditReceta = (receta) => {
    // Los ingredientes vienen como array de objetos, cada objeto tiene un "nombre"
    // que puede contener múltiples ingredientes separados por saltos de línea
    let ingredientesStr = '';
    if (receta?.ingredientes && Array.isArray(receta.ingredientes)) {
      ingredientesStr = receta.ingredientes
        .map(i => i.nombre || i)
        .filter(i => i) // Filtrar valores vacíos
        .join('\n\n'); // Unir con doble salto de línea si hay múltiples objetos
    }
    
    setEditFormData({
      nombre: receta?.nombre || '',
      urlImagen: receta?.urlImagen || '',
      preparacion: receta?.preparacion || '',
      ingredientes: ingredientesStr
    });
    setEditDialogOpen(true);
  };

  const handleCloseEditDialog = () => {
    setEditDialogOpen(false);
    setEditFormData({
      nombre: '',
      urlImagen: '',
      preparacion: '',
      ingredientes: ''
    });
  };

  const handleEditFormChange = (field, value) => {
    setEditFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const handleSubmitEdit = async () => {
    if(!selectedReceta) return;
    try {
      const recetaId = selectedReceta.idReceta || selectedReceta.id;
      
      // El backend espera un array con objetos que tienen la propiedad "nombre"
      // El texto de ingredientes se mantiene como está (con saltos de línea internos)
      // Solo lo envolvemos en un objeto dentro de un array
      const ingredientesArray = editFormData.ingredientes.trim() 
        ? [{ nombre: editFormData.ingredientes }]
        : [];
      
      // Preparar datos para enviar
      const dataToSend = {
        nombre: editFormData.nombre,
        urlImagen: editFormData.urlImagen,
        preparacion: editFormData.preparacion,
        ingredientes: ingredientesArray
      };
      
      await putReceta(recetaId, dataToSend);
      
      // Recargar las recetas
      await loadRecetas();
      
      // Cerrar modales
      handleCloseEditDialog();
      handleCloseReceta();
      
      // Mostrar mensaje de éxito
      setSnackbar({
        open: true,
        message: 'Receta actualizada exitosamente',
        severity: 'success'
      });
    } catch(e) {
      console.error('Error al actualizar receta:', e);
      setSnackbar({
        open: true,
        message: 'Error al actualizar la receta',
        severity: 'error'
      });
    }
  };

  const handleSubmitComentario = async () => {
    if(!isAuthenticated()){ setAuthPromptOpen(true); return; }
    if(!newComentario || !newComentario.trim()) return;
    try{
      const recetaId = selectedReceta?.idReceta || selectedReceta?.id;
      await postComentarioReceta(recetaId, newComentario);
      setNewComentario('');
      await loadComentarios(recetaId);
    }catch(e){}
  };

  // Aplicar filtros
  const filteredRecetas = mine.filter(r => {
    // Filtro por nombre
    if(searchNombre && searchNombre.trim()) {
      const s = searchNombre.trim().toLowerCase();
      if(!(r.nombre || '').toString().toLowerCase().includes(s)) {
        return false;
      }
    }
    
    // Filtro por país
    if(selectedPais) {
      const recetaPaisId = r.idPais || r.id_pais || r.pais?.idPais || r.pais?.id;
      const selectedPaisId = selectedPais.idPais || selectedPais.id;
      if(recetaPaisId !== selectedPaisId) {
        return false;
      }
    }
    
    // Filtro por categoría
    if(selectedCategoria) {
      const recetaCategoriaId = r.idCat || r.idCategoria || r.id_categoria || r.categoria?.idCat || r.categoria?.idCategoria || r.categoria?.id;
      const selectedCategoriaId = selectedCategoria.idCat || selectedCategoria.idCategoria || selectedCategoria.id;
      if(recetaCategoriaId !== selectedCategoriaId) {
        return false;
      }
    }
    
    // Filtro por rango de fechas
    if(fechaDesde || fechaHasta) {
      const recetaFecha = r.fechaCreacion || r.fecha_creacion;
      if(recetaFecha) {
        const fechaReceta = new Date(recetaFecha);
        
        if(fechaDesde) {
          const desde = new Date(fechaDesde);
          desde.setHours(0, 0, 0, 0);
          if(fechaReceta < desde) {
            return false;
          }
        }
        
        if(fechaHasta) {
          const hasta = new Date(fechaHasta);
          hasta.setHours(23, 59, 59, 999);
          if(fechaReceta > hasta) {
            return false;
          }
        }
      }
    }
    
    return true;
  });

  // Aplicar ordenamiento por estrellas
  const sortedRecetas = sortByStars ? [...filteredRecetas].sort((a, b) => {
    const recetaIdA = a.idReceta || a.id;
    const recetaIdB = b.idReceta || b.id;
    const starsA = recetasWithStars.get(recetaIdA) || 0;
    const starsB = recetasWithStars.get(recetaIdB) || 0;
    
    if(sortByStars === 'asc') {
      return starsA - starsB;
    } else if(sortByStars === 'desc') {
      return starsB - starsA;
    }
    return 0;
  }) : filteredRecetas;

  const paginatedRecetas = sortedRecetas.slice((page - 1) * rows, page * rows);
  const totalPages = Math.ceil(sortedRecetas.length / rows);
  
  const shortText = (text, n = 100) => text ? (text.length > n ? text.slice(0, n).trim() + '...' : text) : '';

  // Funciones para manejar filtros
  const handleApplyFilters = () => {
    // Aplicar los filtros temporales a los filtros reales
    setSelectedPais(tempSelectedPais);
    setSelectedCategoria(tempSelectedCategoria);
    setSearchNombre(tempSearchNombre);
    setSortByStars(tempSortByStars);
    setFechaDesde(tempFechaDesde);
    setFechaHasta(tempFechaHasta);
    setFilterDrawerOpen(false);
    setPage(1); // Resetear a la primera página al aplicar filtros
  };

  const handleResetFilters = () => {
    setTempSelectedPais(null);
    setTempSelectedCategoria(null);
    setTempSearchNombre('');
    setTempSortByStars('');
    setTempFechaDesde('');
    setTempFechaHasta('');
    setSelectedPais(null);
    setSelectedCategoria(null);
    setSearchNombre('');
    setSortByStars('');
    setFechaDesde('');
    setFechaHasta('');
    setPage(1);
  };
  
  const handleOpenFilterDrawer = () => {
    // Sincronizar los estados temporales con los actuales al abrir el drawer
    setTempSelectedPais(selectedPais);
    setTempSelectedCategoria(selectedCategoria);
    setTempSearchNombre(searchNombre);
    setTempSortByStars(sortByStars);
    setTempFechaDesde(fechaDesde);
    setTempFechaHasta(fechaHasta);
    setFilterDrawerOpen(true);
  };

  return (
    <Box>
      <Box sx={{ 
        background: 'linear-gradient(135deg, #667EEA 0%, #764BA2 100%)', 
        py: { xs: 4, md: 6 }
      }}>
        <Container>
          <Box textAlign="center">
            <Typography variant="h3" sx={{ 
              color: 'white', 
              fontFamily: 'Lato, sans-serif', 
              fontWeight: 900,
              textShadow: '2px 2px 4px rgba(0,0,0,0.2)',
              fontSize: { xs: '2rem', sm: '2.5rem', md: '3rem' }
            }}>
              Tus Recetas
            </Typography>
            <Typography sx={{
              color: 'white',
              fontFamily: 'Open Sans, sans-serif',
              fontWeight: 600,
              fontSize: { xs: '0.95rem', sm: '1rem', md: '1.1rem' },
              mt: 1,
              textShadow: '1px 1px 2px rgba(0,0,0,0.1)'
            }}>
              {mine.length} {mine.length === 1 ? 'receta' : 'recetas'}
            </Typography>
          </Box>
        </Container>
      </Box>

      <Container maxWidth="xl" sx={{ py: { xs: 3, md: 5 }, px: 2, mx: 'auto' }}>
        {loading && <Typography>Cargando...</Typography>}
        
        {/* Botón de filtros */}
        <Box sx={{ mb: 3, display: 'flex', justifyContent: 'flex-start' }}>
          <Button 
            variant="contained" 
            startIcon={<FilterListIcon />} 
            onClick={handleOpenFilterDrawer}
            size="small"
            sx={{ 
              background: 'linear-gradient(135deg, #667EEA 0%, #764BA2 100%)',
              color: 'white',
              fontFamily: 'Open Sans, sans-serif',
              fontWeight: 700,
              borderRadius: 50,
              px: 3,
              boxShadow: '0 4px 12px rgba(102, 126, 234, 0.3)',
              '&:hover': { 
                background: 'linear-gradient(135deg, #764BA2 0%, #667EEA 100%)',
                boxShadow: '0 6px 16px rgba(102, 126, 234, 0.4)',
                transform: 'translateY(-2px)'
              },
              transition: 'all 0.3s ease'
            }}
          >
            Filtros
          </Button>
        </Box>
        
        <Grid container spacing={3} justifyContent="flex-start">
          {(!mine || mine.length === 0) && !loading && (
            <Grid item xs={12}>
              <Typography textAlign="center" color="text.secondary">
                No has creado recetas todavía.
              </Typography>
            </Grid>
          )}
          
          {paginatedRecetas.map(r => {
            const recetaId = r.idReceta || r.id;
            const isFav = userInteractions.favoritos.get(recetaId);
            const hasLike = userInteractions.likes.get(recetaId);
            const hasStar = userInteractions.estrellas.has(recetaId);
            
            return (
              <Grid item key={recetaId} xs={12} sm={6} sx={{ width: 'calc(50% - 12px)' }}>
                <Box sx={{ 
                  borderRadius: 3,
                  overflow: 'hidden',
                  width: '100%',
                  height: 520,
                  display: 'flex', 
                  flexDirection: 'column',
                  boxShadow: '0 4px 12px rgba(102, 126, 234, 0.1)',
                  transition: 'all 0.3s ease',
                  '&:hover': {
                    transform: 'translateY(-8px)',
                    boxShadow: '0 8px 24px rgba(102, 126, 234, 0.2)'
                  }
                }}>
                  {/* CONTENEDOR DE IMAGEN */}
                  <Box sx={{ 
                    width: '100%', 
                    height: 300,
                    overflow: 'hidden',
                    flexShrink: 0,
                    backgroundColor: '#f5f5f5',
                    position: 'relative'
                  }}>
                    <Box 
                      component="img" 
                      src={r.urlImagen || 'https://placehold.co/600x360'} 
                      alt={r.nombre} 
                      onError={(e)=>{ e.target.src='https://placehold.co/600x360'; }} 
                      sx={{ 
                        position: 'absolute',
                        top: 0,
                        left: 0,
                        width: '100%',
                        height: '100%',
                        objectFit: 'cover'
                      }}
                    />
                  </Box>
                  
                  {/* CONTENIDO DE LA TARJETA */}
                  <Box sx={{ 
                    p: 2.5, 
                    flexGrow: 1, 
                    display: 'flex', 
                    flexDirection: 'column', 
                    justifyContent: 'space-between' 
                  }}>
                    <Typography sx={{ 
                      fontFamily: 'Lato, sans-serif', 
                      fontWeight: 900,
                      color: '#1A202C',
                      fontSize: '1.1rem',
                      mb: 2,
                      overflow: 'hidden',
                      textOverflow: 'ellipsis',
                      display: '-webkit-box',
                      WebkitLineClamp: 2,
                      WebkitBoxOrient: 'vertical',
                      minHeight: '2.6em'
                    }}>
                      {r.nombre}
                    </Typography>
                    
                    <Box>
                      <Typography variant="caption" sx={{ 
                        color: '#969696', 
                        fontFamily: 'Open Sans, sans-serif',
                        display: 'block',
                        mb: 1
                      }}>
                        {formatFecha(r.fechaCreacion)}
                      </Typography>
                      <Box sx={{ display: 'flex', gap: 0.5, justifyContent: 'flex-start' }}>
                        <IconButton 
                          size="small" 
                          onClick={() => handleLike(recetaId)} 
                          aria-label="like"
                          sx={{
                            backgroundColor: hasLike ? '#4299E1' : '#F7FAFC',
                            color: hasLike ? 'white' : '#4299E1',
                            '&:hover': {
                              backgroundColor: '#4299E1',
                              color: 'white'
                            }
                          }}
                        >
                          {hasLike 
                            ? <ThumbUpIcon fontSize="small" /> 
                            : <ThumbUpOutlinedIcon fontSize="small" />
                          }
                        </IconButton>
                        <IconButton 
                          size="small" 
                          onClick={() => handleOpenRating(recetaId, r.nombre)} 
                          aria-label="star"
                          sx={{
                            backgroundColor: hasStar ? '#ED8936' : '#F7FAFC',
                            color: hasStar ? 'white' : '#ED8936',
                            '&:hover': {
                              backgroundColor: '#ED8936',
                              color: 'white'
                            }
                          }}
                        >
                          {hasStar 
                            ? <StarIcon fontSize="small" /> 
                            : <StarBorderIcon fontSize="small" />
                          }
                        </IconButton>
                        <IconButton 
                          size="small" 
                          onClick={() => handleFavorite(recetaId)} 
                          aria-label="fav"
                          sx={{
                            backgroundColor: isFav ? '#F56565' : '#F7FAFC',
                            color: isFav ? 'white' : '#F56565',
                            '&:hover': {
                              backgroundColor: '#F56565',
                              color: 'white'
                            }
                          }}
                        >
                          {isFav 
                            ? <BookmarkIcon fontSize="small" /> 
                            : <BookmarkBorderIcon fontSize="small" />
                          }
                        </IconButton>
                      </Box>
                    </Box>
                    
                    <Button 
                      onClick={() => handleOpenReceta(r)} 
                      fullWidth
                      variant="contained"
                      sx={{
                        mt: 2,
                        background: 'linear-gradient(135deg, #F093FB 0%, #F5576C 100%)',
                        color: 'white',
                        fontFamily: 'Open Sans, sans-serif',
                        fontWeight: 700,
                        borderRadius: 50,
                        py: { xs: 0.8, sm: 1 },
                        fontSize: { xs: '0.875rem', sm: '0.9375rem' },
                        '&:hover': {
                          background: 'linear-gradient(135deg, #F5576C 0%, #F093FB 100%)',
                          transform: 'translateY(-2px)',
                          boxShadow: '0 4px 12px rgba(240, 147, 251, 0.4)'
                        },
                        transition: 'all 0.3s ease'
                      }}
                    >
                      Ver receta
                    </Button>
                  </Box>
                </Box>
              </Grid>
            );
          })}
        </Grid>

        {totalPages > 1 && (
          <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
            <Pagination 
              count={totalPages} 
              page={page} 
              onChange={(e, val) => setPage(val)} 
              color="primary" 
            />
          </Box>
        )}

        {/* Modal de detalle de receta */}
        <Dialog open={openReceta} onClose={handleCloseReceta} fullWidth maxWidth="md">
          <DialogTitle sx={{ 
            fontFamily: 'Lato, sans-serif', 
            fontWeight: 900,
            color: '#1A202C',
            fontSize: { xs: '1.5rem', md: '1.75rem' },
            borderBottom: '3px solid rgba(102, 126, 234, 0.3)',
            pb: 2
          }}>
            {selectedReceta?.nombre}
          </DialogTitle>
          <DialogContent dividers sx={{ p: { xs: 2, md: 3 } }}>
            <Box 
              component="img" 
              src={selectedReceta?.urlImagen || 'https://placehold.co/800x480'} 
              alt={selectedReceta?.nombre} 
              onError={(e)=>{ e.target.src='https://placehold.co/800x480'; }} 
              sx={{ 
                width: '100%', 
                height: { xs: 240, md: 360 },
                objectFit: 'cover',
                borderRadius: 3,
                mb: 3,
                boxShadow: '0 4px 12px rgba(0,0,0,0.1)'
              }} 
            />
            
            <Typography variant="h6" sx={{ 
              fontFamily: 'Roboto, sans-serif', 
              fontWeight: 900,
              color: '#99682E',
              mb: 2,
              fontSize: '1.25rem'
            }}>
              Ingredientes
            </Typography>
            <Typography sx={{ 
              fontFamily: 'Open Sans, sans-serif', 
              color: '#969696',
              mb: 3,
              fontSize: '1rem',
              lineHeight: 1.7,
              whiteSpace: 'pre-wrap'
            }}>
              {selectedReceta?.ingredientes 
                ? (Array.isArray(selectedReceta.ingredientes) 
                    ? selectedReceta.ingredientes.map(ing => typeof ing === 'string' ? ing : ing.nombre).join(', ')
                    : selectedReceta.ingredientes)
                : 'No disponible'}
            </Typography>
            
            <Divider sx={{ my: 3 }} />
            
            <Typography variant="h6" sx={{ 
              fontFamily: 'Roboto, sans-serif', 
              fontWeight: 900,
              color: '#99682E',
              mb: 2,
              fontSize: '1.25rem'
            }}>
              Preparación
            </Typography>
            <Typography sx={{ 
              fontFamily: 'Open Sans, sans-serif', 
              color: '#969696',
              mb: 3,
              fontSize: '1rem',
              lineHeight: 1.7,
              whiteSpace: 'pre-wrap'
            }}>
              {selectedReceta?.preparacion || 'No disponible'}
            </Typography>
            
            <Divider sx={{ my: 3 }} />
            
            {/* Botones de interacción con estadísticas */}
            <Box sx={{ 
              display: 'flex', 
              alignItems: 'center', 
              justifyContent: 'space-between', 
              flexWrap: 'wrap', 
              gap: 2,
              backgroundColor: '#F9E9AE',
              borderRadius: 2,
              p: 2
            }}>
              {/* Botones e interacciones de izquierda */}
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                {/* Botón Me Gusta con contador */}
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                  <IconButton 
                    aria-label="like" 
                    onClick={() => handleLike(selectedReceta?.idReceta || selectedReceta?.id)}
                    sx={{
                      backgroundColor: userInteractions.likes.has(selectedReceta?.idReceta || selectedReceta?.id) ? '#F75442' : 'white',
                      color: userInteractions.likes.has(selectedReceta?.idReceta || selectedReceta?.id) ? 'white' : '#F75442',
                      '&:hover': {
                        backgroundColor: '#FA968B',
                        color: 'white'
                      }
                    }}
                  >
                    {userInteractions.likes.has(selectedReceta?.idReceta || selectedReceta?.id) ? <ThumbUpIcon /> : <ThumbUpOutlinedIcon />}
                  </IconButton>
                  <Typography variant="body2" sx={{ fontWeight: 700, color: '#2F4295' }}>
                    {modalStats.meGustas}
                  </Typography>
                </Box>
                
                {/* Botón Estrellas con promedio */}
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                  <IconButton 
                    aria-label="star" 
                    onClick={() => handleOpenRating(selectedReceta?.idReceta || selectedReceta?.id, selectedReceta?.nombre)}
                    sx={{
                      backgroundColor: userInteractions.estrellas.has(selectedReceta?.idReceta || selectedReceta?.id) ? '#99682E' : 'white',
                      color: userInteractions.estrellas.has(selectedReceta?.idReceta || selectedReceta?.id) ? 'white' : '#99682E',
                      '&:hover': {
                        backgroundColor: '#99682E',
                        color: 'white'
                      }
                    }}
                  >
                    {userInteractions.estrellas.has(selectedReceta?.idReceta || selectedReceta?.id) ? <StarIcon /> : <StarBorderIcon />}
                  </IconButton>
                  <Typography variant="body2" sx={{ fontWeight: 700, color: '#2F4295' }}>
                    {modalStats.estrellas.promedio > 0 ? modalStats.estrellas.promedio.toFixed(1) : '0.0'}
                    <Typography component="span" variant="body2" sx={{ ml: 0.5, color: '#969696', fontWeight: 400 }}>
                      ({modalStats.estrellas.total})
                    </Typography>
                  </Typography>
                </Box>
              </Box>
              
              {/* Botón Favorito a la derecha */}
              <IconButton 
                aria-label="fav" 
                onClick={() => handleFavorite(selectedReceta?.idReceta || selectedReceta?.id)}
                sx={{
                  backgroundColor: userInteractions.favoritos.has(selectedReceta?.idReceta || selectedReceta?.id) ? '#F75442' : 'white',
                  color: userInteractions.favoritos.has(selectedReceta?.idReceta || selectedReceta?.id) ? 'white' : '#F75442',
                  '&:hover': {
                    backgroundColor: '#FA968B',
                    color: 'white'
                  }
                }}
              >
                {userInteractions.favoritos.has(selectedReceta?.idReceta || selectedReceta?.id) ? <BookmarkIcon /> : <BookmarkBorderIcon />}
              </IconButton>
            </Box>
            
            
            <Typography variant="h6" sx={{ 
              fontFamily: 'Roboto, sans-serif', 
              fontWeight: 900,
              color: '#99682E',
              mb: 2,
              fontSize: '1.25rem'
            }}>
              Comentarios
            </Typography>
            
            {comentarios.length === 0 ? (
              <Typography sx={{ 
                fontFamily: 'Open Sans, sans-serif', 
                color: '#969696',
                fontStyle: 'italic',
                mb: 2
              }}>
                No hay comentarios aún. ¡Sé el primero en comentar!
              </Typography>
            ) : (
              <List sx={{ mb: 2 }}>
                {comentarios.map((c, idx) => (
                  <ListItem 
                    key={idx} 
                    sx={{ 
                      backgroundColor: '#F9E9AE',
                      borderRadius: 2,
                      mb: 1,
                      flexDirection: 'column',
                      alignItems: 'flex-start'
                    }}
                  >
                    <ListItemText
                      primary={
                        <Typography sx={{ 
                          fontFamily: 'Open Sans, sans-serif', 
                          fontWeight: 700,
                          color: '#1A202C',
                          fontSize: '0.95rem'
                        }}>
                          {c.nombreUsuario || 'Usuario'}
                        </Typography>
                      }
                      secondary={
                        <Typography sx={{ 
                          fontFamily: 'Open Sans, sans-serif', 
                          color: '#4A5568',
                          fontSize: '0.9rem',
                          mt: 0.5
                        }}>
                          {c.comentario || c.texto}
                        </Typography>
                      }
                    />
                    <Typography variant="caption" sx={{ 
                      color: '#718096',
                      fontFamily: 'Open Sans, sans-serif',
                      mt: 0.5
                    }}>
                      {formatFecha(c.fechaCreacion || c.fecha)}
                    </Typography>
                  </ListItem>
                ))}
              </List>
            )}
            
            <Box sx={{ display: 'flex', gap: 1, mt: 2 }}>
              <TextField
                fullWidth
                size="small"
                placeholder="Escribe un comentario..."
                value={newComentario}
                onChange={(e) => setNewComentario(e.target.value)}
                sx={{
                  '& .MuiOutlinedInput-root': {
                    borderRadius: 50,
                    borderColor: '#F75442',
                    fontFamily: 'Open Sans, sans-serif'
                  }
                }}
              />
              <Button 
                size="small" 
                variant="contained" 
                onClick={handleSubmitComentario}
                sx={{
                  background: '#F75442',
                  color: 'white',
                  borderRadius: 50,
                  px: 3,
                  fontFamily: 'Open Sans, sans-serif',
                  fontWeight: 700,
                  boxShadow: 'none',
                  '&:hover': {
                    background: '#d43f2f',
                    boxShadow: '0 4px 8px rgba(247, 84, 66, 0.3)'
                  }
                }}
              >
                Enviar
              </Button>
            </Box>
          </DialogContent>
          <DialogActions sx={{ bgcolor: '#F7FAFC' }}>
            <Button 
              onClick={() => handleEditReceta(selectedReceta)} 
              startIcon={<EditIcon />} 
              sx={{
                color: '#667EEA',
                borderColor: '#667EEA',
                '&:hover': { 
                  borderColor: '#5568D3',
                  bgcolor: 'rgba(102, 126, 234, 0.1)'
                }
              }}
              variant="outlined"
            >
              Editar
            </Button>
            <Button 
              onClick={handleCloseReceta}
              sx={{
                color: '#718096',
                '&:hover': { bgcolor: 'rgba(113, 128, 150, 0.1)' }
              }}
            >
              Cerrar
            </Button>
          </DialogActions>
        </Dialog>

        <AuthPromptDialog open={authPromptOpen} onClose={() => setAuthPromptOpen(false)} />
        <RatingDialog 
          open={ratingDialogOpen} 
          onClose={() => setRatingDialogOpen(false)} 
          onRate={handleRate}
          onDelete={handleDeleteRating}
          recetaNombre={ratingRecetaNombre}
          hasRating={userInteractions.estrellas.has(ratingRecetaId)}
        />

        {/* Modal de edición de receta */}
        <Dialog 
          open={editDialogOpen} 
          onClose={handleCloseEditDialog} 
          fullWidth 
          maxWidth="md"
          PaperProps={{
            sx: {
              borderRadius: 3
            }
          }}
        >
          <DialogTitle sx={{ 
            fontFamily: 'Lato, sans-serif', 
            fontWeight: 900,
            color: '#1A202C',
            fontSize: '1.5rem',
            borderBottom: '2px solid #F093FB'
          }}>
            Editar Receta
          </DialogTitle>
          <DialogContent dividers sx={{ p: 3 }}>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2.5 }}>
              {/* Nombre de la receta */}
              <TextField
                label="Nombre de la receta"
                fullWidth
                value={editFormData.nombre}
                onChange={(e) => handleEditFormChange('nombre', e.target.value)}
                required
                sx={{
                  '& .MuiOutlinedInput-root': {
                    borderRadius: 2,
                    fontFamily: 'Open Sans, sans-serif',
                    '&.Mui-focused fieldset': {
                      borderColor: '#667EEA'
                    }
                  },
                  '& .MuiInputLabel-root.Mui-focused': {
                    color: '#667EEA',
                    fontFamily: 'Open Sans, sans-serif',
                    fontWeight: 600
                  }
                }}
              />

              {/* URL de la imagen */}
              <TextField
                label="URL de la imagen"
                fullWidth
                value={editFormData.urlImagen}
                onChange={(e) => handleEditFormChange('urlImagen', e.target.value)}
                placeholder="https://ejemplo.com/imagen.jpg"
                sx={{
                  '& .MuiOutlinedInput-root': {
                    borderRadius: 2,
                    fontFamily: 'Open Sans, sans-serif',
                    '&.Mui-focused fieldset': {
                      borderColor: '#667EEA'
                    }
                  },
                  '& .MuiInputLabel-root.Mui-focused': {
                    color: '#667EEA',
                    fontFamily: 'Open Sans, sans-serif',
                    fontWeight: 600
                  }
                }}
              />

              {/* Vista previa de la imagen */}
              {editFormData.urlImagen && (
                <Box
                  component="img"
                  src={editFormData.urlImagen}
                  alt="Vista previa"
                  onError={(e) => { e.target.style.display = 'none'; }}
                  sx={{ 
                    width: '100%', 
                    maxHeight: 300, 
                    objectFit: 'cover', 
                    borderRadius: 3,
                    border: '2px solid #E2E8F0',
                    boxShadow: '0 4px 12px rgba(102, 126, 234, 0.1)'
                  }}
                />
              )}

              {/* Ingredientes */}
              <TextField
                label="Ingredientes"
                fullWidth
                multiline
                rows={6}
                value={editFormData.ingredientes}
                onChange={(e) => handleEditFormChange('ingredientes', e.target.value)}
                placeholder="Lista los ingredientes separados por comas o saltos de línea..."
                required
                sx={{
                  '& .MuiOutlinedInput-root': {
                    borderRadius: 2,
                    fontFamily: 'Open Sans, sans-serif',
                    '&.Mui-focused fieldset': {
                      borderColor: '#667EEA'
                    }
                  },
                  '& .MuiInputLabel-root.Mui-focused': {
                    color: '#667EEA',
                    fontFamily: 'Open Sans, sans-serif',
                    fontWeight: 600
                  }
                }}
              />

              {/* Preparación */}
              <TextField
                label="Preparación"
                fullWidth
                multiline
                rows={6}
                value={editFormData.preparacion}
                onChange={(e) => handleEditFormChange('preparacion', e.target.value)}
                placeholder="Describe los pasos para preparar la receta..."
                required
                sx={{
                  '& .MuiOutlinedInput-root': {
                    borderRadius: 2,
                    fontFamily: 'Open Sans, sans-serif',
                    '&.Mui-focused fieldset': {
                      borderColor: '#667EEA'
                    }
                  },
                  '& .MuiInputLabel-root.Mui-focused': {
                    color: '#667EEA',
                    fontFamily: 'Open Sans, sans-serif',
                    fontWeight: 600
                  }
                }}
              />
            </Box>
          </DialogContent>
          <DialogActions sx={{ p: 2.5, gap: 1 }}>
            <Button 
              onClick={handleCloseEditDialog}
              sx={{
                fontFamily: 'Open Sans, sans-serif',
                fontWeight: 600,
                color: '#718096',
                borderRadius: 50,
                px: 3,
                '&:hover': {
                  backgroundColor: '#F7FAFC'
                }
              }}
            >
              Cancelar
            </Button>
            <Button 
              onClick={handleSubmitEdit} 
              variant="contained"
              disabled={!editFormData.nombre || !editFormData.preparacion}
              sx={{
                fontFamily: 'Open Sans, sans-serif',
                fontWeight: 700,
                borderRadius: 50,
                px: 3,
                background: 'linear-gradient(135deg, #F093FB 0%, #F5576C 100%)',
                color: 'white',
                '&:hover': {
                  background: 'linear-gradient(135deg, #F5576C 0%, #F093FB 100%)',
                  transform: 'translateY(-2px)',
                  boxShadow: '0 4px 12px rgba(240, 147, 251, 0.4)'
                },
                '&.Mui-disabled': {
                  background: '#E2E8F0',
                  color: '#A0AEC0'
                },
                transition: 'all 0.3s ease'
              }}
            >
              Guardar cambios
            </Button>
          </DialogActions>
        </Dialog>

        {/* Drawer de filtros */}
        <Drawer
          anchor="right"
          open={filterDrawerOpen}
          onClose={() => setFilterDrawerOpen(false)}
        >
          <Box sx={{ width: 300, p: 3 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
              <Typography variant="h6" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>
                Filtros
              </Typography>
              <IconButton size="small" onClick={() => setFilterDrawerOpen(false)}>
                <CloseIcon />
              </IconButton>
            </Box>

            <Divider sx={{ mb: 3 }} />

            {/* Filtro por nombre */}
            <TextField
              label="Buscar por nombre"
              size="small"
              fullWidth
              value={tempSearchNombre}
              onChange={(e) => setTempSearchNombre(e.target.value)}
              sx={{ mb: 2 }}
              placeholder="Nombre de la receta..."
            />

            {/* Filtro por País */}
            <Autocomplete
              options={paises}
              getOptionLabel={(option) => option.nombre || ''}
              value={tempSelectedPais}
              onChange={(event, newValue) => setTempSelectedPais(newValue)}
              renderInput={(params) => (
                <TextField {...params} label="País" size="small" />
              )}
              sx={{ mb: 2 }}
            />

            {/* Filtro por Categoría */}
            <Autocomplete
              options={categorias}
              getOptionLabel={(option) => option.nombre || ''}
              value={tempSelectedCategoria}
              onChange={(event, newValue) => setTempSelectedCategoria(newValue)}
              renderInput={(params) => (
                <TextField {...params} label="Categoría" size="small" />
              )}
              sx={{ mb: 2 }}
            />

            {/* Ordenar por estrellas */}
            <FormControl fullWidth size="small" sx={{ mb: 2 }}>
              <InputLabel>Ordenar por estrellas</InputLabel>
              <Select
                value={tempSortByStars}
                label="Ordenar por estrellas"
                onChange={(e) => setTempSortByStars(e.target.value)}
              >
                <MenuItem value="">Sin ordenar</MenuItem>
                <MenuItem value="asc">Menor a mayor ⭐</MenuItem>
                <MenuItem value="desc">Mayor a menor ⭐</MenuItem>
              </Select>
            </FormControl>

            {/* Filtro por rango de fechas */}
            <Typography variant="subtitle2" sx={{ mb: 1, fontWeight: 600, color: 'text.secondary' }}>
              Filtrar por fecha
            </Typography>
            
            <TextField
              label="Fecha desde"
              type="date"
              size="small"
              fullWidth
              value={tempFechaDesde}
              onChange={(e) => setTempFechaDesde(e.target.value)}
              sx={{ mb: 2 }}
              InputLabelProps={{
                shrink: true,
              }}
            />

            <TextField
              label="Fecha hasta"
              type="date"
              size="small"
              fullWidth
              value={tempFechaHasta}
              onChange={(e) => setTempFechaHasta(e.target.value)}
              sx={{ mb: 2 }}
              InputLabelProps={{
                shrink: true,
              }}
            />

            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1, mt: 3 }}>
              <Button 
                variant="contained" 
                fullWidth
                onClick={handleApplyFilters}
              >
                Aplicar Filtros
              </Button>
              <Button 
                variant="outlined" 
                fullWidth
                onClick={handleResetFilters}
              >
                Limpiar Filtros
              </Button>
            </Box>
          </Box>
        </Drawer>

        {/* Snackbar para notificaciones */}
        <Snackbar 
          open={snackbar.open} 
          autoHideDuration={3000}
          onClose={() => setSnackbar({ ...snackbar, open: false })}
          anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
        >
          <Alert 
            onClose={() => setSnackbar({ ...snackbar, open: false })} 
            severity={snackbar.severity}
            variant="filled"
            sx={{ 
              width: '100%',
              fontFamily: 'Open Sans, sans-serif',
              fontWeight: 600
            }}
          >
            {snackbar.message}
          </Alert>
        </Snackbar>
      </Container>
    </Box>
  );
}
