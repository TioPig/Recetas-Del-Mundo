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
import { getRecetas, putReceta, postLikeReceta, deleteLikeReceta, postStarReceta, deleteStarReceta, postFavoritoReceta, deleteFavoritoReceta, getComentariosReceta, postComentarioReceta, isAuthenticated, getEstrellaStats, getMeGustaCount, getFavoritos, getMeGustas, getEstrellas, getPaises, getCategorias, formatFecha } from '../api';
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
      setComentarios(list);
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
    setEditFormData({
      nombre: receta?.nombre || '',
      urlImagen: receta?.urlImagen || '',
      preparacion: receta?.preparacion || '',
      ingredientes: (receta?.ingredientes || []).map(i => i.nombre || i)
    });
    setEditDialogOpen(true);
  };

  const handleCloseEditDialog = () => {
    setEditDialogOpen(false);
    setEditFormData({
      nombre: '',
      urlImagen: '',
      preparacion: '',
      ingredientes: []
    });
  };

  const handleEditFormChange = (field, value) => {
    setEditFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const handleIngredienteChange = (index, value) => {
    const newIngredientes = [...editFormData.ingredientes];
    newIngredientes[index] = value;
    setEditFormData(prev => ({
      ...prev,
      ingredientes: newIngredientes
    }));
  };

  const handleAddIngrediente = () => {
    setEditFormData(prev => ({
      ...prev,
      ingredientes: [...prev.ingredientes, '']
    }));
  };

  const handleRemoveIngrediente = (index) => {
    setEditFormData(prev => ({
      ...prev,
      ingredientes: prev.ingredientes.filter((_, i) => i !== index)
    }));
  };

  const handleSubmitEdit = async () => {
    if(!selectedReceta) return;
    try {
      const recetaId = selectedReceta.idReceta || selectedReceta.id;
      
      // Preparar datos para enviar
      const dataToSend = {
        nombre: editFormData.nombre,
        urlImagen: editFormData.urlImagen,
        preparacion: editFormData.preparacion,
        ingredientes: editFormData.ingredientes.filter(i => i.trim() !== '').map(nombre => ({ nombre }))
      };
      
      await putReceta(recetaId, dataToSend);
      
      // Recargar las recetas
      await loadRecetas();
      
      // Cerrar modales
      handleCloseEditDialog();
      handleCloseReceta();
      
      // Mensaje de éxito (opcional)
      alert('Receta actualizada exitosamente');
    } catch(e) {
      console.error('Error al actualizar receta:', e);
      alert('Error al actualizar la receta');
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
      <Box sx={{ backgroundColor: '#F6F0E0', py: 4 }}>
        <Container>
          <Box textAlign="center">
            <Typography variant="h2" sx={{ color: '#6b4f34', fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>Tus Recetas</Typography>
            <Typography variant="body1" sx={{ color: '#6b4f34', mt: 1 }}>
              {mine.length} {mine.length === 1 ? 'receta' : 'recetas'}
            </Typography>
          </Box>
        </Container>
      </Box>

      <Container maxWidth="xl" sx={{ py: 4, px: 2, maxWidth: '1400px', mx: 'auto' }}>
        {loading && <Typography>Cargando...</Typography>}
        
        {/* Botón de filtros */}
        <Box sx={{ mb: 3, display: 'flex', justifyContent: 'flex-start' }}>
          <Button 
            variant="contained" 
            startIcon={<FilterListIcon />} 
            onClick={handleOpenFilterDrawer}
            size="small"
            sx={{ backgroundColor: '#F75442', '&:hover': { backgroundColor: '#d43f2f' } }}
          >
            Filtros
          </Button>
        </Box>
        
        <Grid container spacing={2} justifyContent="center">
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
              <Grid item key={recetaId} sx={{ width: { xs: '100%', sm: '48%', md: '23%' } }}>
                <Box sx={{ border: '1px solid #eee', p: 2, borderRadius: 1, height: '100%', display: 'flex', flexDirection: 'column', boxSizing: 'border-box', width: '100%' }}>
                  <Box 
                    component="img" 
                    src={r.urlImagen || 'https://placehold.co/600x360'} 
                    alt={r.nombre} 
                    onError={(e)=>{ e.target.src='https://placehold.co/600x360'; }} 
                    sx={{ width: '100%', height: 120, maxHeight: 140, objectFit: 'cover', borderRadius: 1 }}
                  />
                  <Typography sx={{ mt: 1, fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>
                    {r.nombre}
                  </Typography>
                  <Typography color="text.secondary" sx={{ mt: 1, flexGrow: 1 }}>
                    {shortText(r.preparacion, 100)}
                  </Typography>
                  
                  <Box sx={{ mt: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <Typography variant="caption" color="text.secondary">
                      {formatFecha(r.fechaCreacion)}
                    </Typography>
                    <Box>
                      <IconButton size="small" onClick={() => handleLike(recetaId)} aria-label="like">
                        {hasLike ? <ThumbUpIcon fontSize="small" color="primary" /> : <ThumbUpOutlinedIcon fontSize="small" />}
                      </IconButton>
                      <IconButton size="small" onClick={() => handleOpenRating(recetaId, r.nombre)} aria-label="star">
                        {hasStar ? <StarIcon fontSize="small" color="warning" /> : <StarBorderIcon fontSize="small" />}
                      </IconButton>
                      <IconButton size="small" onClick={() => handleFavorite(recetaId)} aria-label="fav">
                        {isFav ? <BookmarkIcon fontSize="small" color="error" /> : <BookmarkBorderIcon fontSize="small" />}
                      </IconButton>
                      <Button onClick={() => handleOpenReceta(r)} size="small" sx={{ fontFamily: 'Open Sans, sans-serif' }}>
                        Ver receta
                      </Button>
                    </Box>
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
          <DialogTitle sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>{selectedReceta?.nombre}</DialogTitle>
          <DialogContent dividers>
            <Box component="img" src={selectedReceta?.urlImagen || 'https://placehold.co/800x480'} alt={selectedReceta?.nombre} onError={(e)=>{ e.target.src='https://placehold.co/800x480'; }} sx={{ width: '100%', height: 360, maxHeight: 480, objectFit: 'cover', borderRadius: 1 }} />
            
            <Typography sx={{ mt: 2, fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>Ingredientes</Typography>
            <Box component="ul" sx={{ pl: 2, mt: 1, mb: 2 }}>
              {(selectedReceta?.ingredientes || []).map(ingrediente => 
                ingrediente.nombre.split('\n').filter(line => line.trim()).map((line, idx) => (
                  <Box component="li" key={`${ingrediente.idIngrediente}-${idx}`} sx={{ listStyleType: 'disc', ml: 1, fontSize: '0.95rem', color: 'text.secondary', mb: 0.5 }}>
                    {line.trim()}
                  </Box>
                ))
              )}
            </Box>
            
            <Typography sx={{ mt: 2, fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>Preparación</Typography>
            <Typography sx={{ whiteSpace: 'pre-wrap', color: 'text.secondary' }}>{selectedReceta?.preparacion}</Typography>
            
            <Divider sx={{ my: 2 }} />
            
            {/* Botones de interacción con estadísticas */}
            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: 2 }}>
              {/* Botones e interacciones de izquierda */}
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                {/* Botón Me Gusta con contador */}
                <IconButton aria-label="like" onClick={() => handleLike(selectedReceta?.idReceta || selectedReceta?.id)}>
                  {userInteractions.likes.has(selectedReceta?.idReceta || selectedReceta?.id) ? <ThumbUpIcon color="primary" /> : <ThumbUpOutlinedIcon />}
                </IconButton>
                <Typography variant="body2" sx={{ fontWeight: 600, mr: 2 }}>
                  {modalStats.meGustas}
                </Typography>
                
                {/* Botón Estrellas con promedio */}
                <IconButton aria-label="star" onClick={() => handleOpenRating(selectedReceta?.idReceta || selectedReceta?.id, selectedReceta?.nombre)}>
                  {userInteractions.estrellas.has(selectedReceta?.idReceta || selectedReceta?.id) ? <StarIcon color="warning" /> : <StarBorderIcon />}
                </IconButton>
                <Typography variant="body2" sx={{ fontWeight: 600 }}>
                  {modalStats.estrellas.promedio > 0 ? modalStats.estrellas.promedio.toFixed(1) : '0.0'}
                  <Typography component="span" variant="body2" sx={{ ml: 0.5, color: 'text.secondary', fontWeight: 400 }}>
                    ({modalStats.estrellas.total})
                  </Typography>
                </Typography>
              </Box>
              
              {/* Botón Favorito a la derecha */}
              <IconButton aria-label="fav" onClick={() => handleFavorite(selectedReceta?.idReceta || selectedReceta?.id)}>
                {userInteractions.favoritos.has(selectedReceta?.idReceta || selectedReceta?.id) ? <BookmarkIcon color="error" /> : <BookmarkBorderIcon />}
              </IconButton>
            </Box>
            
            <Typography sx={{ fontWeight: 700, mt: 2 }}>Comentarios</Typography>
            <List>
              {(comentarios || []).map(c => (
                <ListItem key={c.idComentario || c.id}><ListItemText primary={c.autor || c.usuario?.nombre || c.usuario?.email || c.nombre || 'Anon'} secondary={c.texto || c.comentario} /></ListItem>
              ))}
            </List>
            <Box sx={{ display: 'flex', gap: 1, mt: 1 }}>
              <TextField size="small" fullWidth placeholder="Escribe un comentario..." value={newComentario} onChange={(e)=> setNewComentario(e.target.value)} />
              <Button size="small" variant="contained" onClick={handleSubmitComentario}>Enviar</Button>
            </Box>
          </DialogContent>
          <DialogActions>
            <Button onClick={() => handleEditReceta(selectedReceta)} startIcon={<EditIcon />} color="primary" variant="outlined">
              Editar
            </Button>
            <Button onClick={handleCloseReceta}>Cerrar</Button>
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
        <Dialog open={editDialogOpen} onClose={handleCloseEditDialog} fullWidth maxWidth="md">
          <DialogTitle sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>
            Editar Receta
          </DialogTitle>
          <DialogContent dividers>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
              {/* Nombre de la receta */}
              <TextField
                label="Nombre de la receta"
                fullWidth
                value={editFormData.nombre}
                onChange={(e) => handleEditFormChange('nombre', e.target.value)}
                required
              />

              {/* URL de la imagen */}
              <TextField
                label="URL de la imagen"
                fullWidth
                value={editFormData.urlImagen}
                onChange={(e) => handleEditFormChange('urlImagen', e.target.value)}
                placeholder="https://ejemplo.com/imagen.jpg"
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
                    borderRadius: 1,
                    border: '1px solid #eee'
                  }}
                />
              )}

              {/* Ingredientes */}
              <Box>
                <Typography variant="subtitle1" sx={{ fontWeight: 700, mb: 1 }}>
                  Ingredientes
                </Typography>
                {editFormData.ingredientes.map((ingrediente, index) => (
                  <Box key={index} sx={{ display: 'flex', gap: 1, mb: 1 }}>
                    <TextField
                      fullWidth
                      size="small"
                      value={ingrediente}
                      onChange={(e) => handleIngredienteChange(index, e.target.value)}
                      placeholder={`Ingrediente ${index + 1}`}
                    />
                    <IconButton 
                      color="error" 
                      onClick={() => handleRemoveIngrediente(index)}
                      disabled={editFormData.ingredientes.length === 1}
                    >
                      <DeleteIcon />
                    </IconButton>
                  </Box>
                ))}
                <Button
                  startIcon={<AddIcon />}
                  onClick={handleAddIngrediente}
                  variant="outlined"
                  size="small"
                  sx={{ mt: 1 }}
                >
                  Agregar ingrediente
                </Button>
              </Box>

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
              />
            </Box>
          </DialogContent>
          <DialogActions>
            <Button onClick={handleCloseEditDialog} color="inherit">
              Cancelar
            </Button>
            <Button 
              onClick={handleSubmitEdit} 
              variant="contained" 
              color="primary"
              disabled={!editFormData.nombre || !editFormData.preparacion}
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
      </Container>
    </Box>
  );
}
