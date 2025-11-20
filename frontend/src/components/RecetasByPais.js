import React from 'react';
import { useParams } from 'react-router-dom';
import { useEffect, useState } from 'react';
import Container from '@mui/material/Container';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Grid from '@mui/material/Grid';
import Button from '@mui/material/Button';
import Dialog from '@mui/material/Dialog';
import DialogTitle from '@mui/material/DialogTitle';
import DialogContent from '@mui/material/DialogContent';
import DialogActions from '@mui/material/DialogActions';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemText from '@mui/material/ListItemText';
import IconButton from '@mui/material/IconButton';
import Divider from '@mui/material/Divider';
import Stack from '@mui/material/Stack';
import BookmarkIcon from '@mui/icons-material/Bookmark';
import BookmarkBorderIcon from '@mui/icons-material/BookmarkBorder';
import StarIcon from '@mui/icons-material/Star';
import StarBorderIcon from '@mui/icons-material/StarBorder';
import ThumbUpIcon from '@mui/icons-material/ThumbUp';
import ThumbUpOutlinedIcon from '@mui/icons-material/ThumbUpOutlined';
import TextField from '@mui/material/TextField';
import Drawer from '@mui/material/Drawer';
import Autocomplete from '@mui/material/Autocomplete';
import FilterListIcon from '@mui/icons-material/FilterList';
import CloseIcon from '@mui/icons-material/Close';
import MenuItem from '@mui/material/MenuItem';
import Select from '@mui/material/Select';
import FormControl from '@mui/material/FormControl';
import InputLabel from '@mui/material/InputLabel';
import { getRecetasByPais, getPais, postLikeReceta, deleteLikeReceta, postStarReceta, deleteStarReceta, postFavoritoReceta, deleteFavoritoReceta, getComentariosReceta, postComentarioReceta, isAuthenticated, isAdmin, getEstrellaStats, getMeGustaCount, getFavoritos, getMeGustas, getEstrellas, getPaises, formatFecha, getUserNombre } from '../api';
import AuthPromptDialog from './AuthPromptDialog';
import RatingDialog from './RatingDialog';
import Pagination from '@mui/material/Pagination';
import { useTheme } from '@mui/material/styles';
import useMediaQuery from '@mui/material/useMediaQuery';

export default function RecetasByPais(){
  const { id } = useParams();
  const [recetas, setRecetas] = useState([]);
  const [pais, setPais] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // Estados para filtros
  const [filterDrawerOpen, setFilterDrawerOpen] = useState(false);
  const [paises, setPaises] = useState([]);
  const [selectedPais, setSelectedPais] = useState(null);
  const [searchNombre, setSearchNombre] = useState('');
  const [sortByStars, setSortByStars] = useState('');
  const [recetasWithStars, setRecetasWithStars] = useState(new Map());
  const [fechaDesde, setFechaDesde] = useState('');
  const [fechaHasta, setFechaHasta] = useState('');
  
  // Estados temporales para filtros
  const [tempSelectedPais, setTempSelectedPais] = useState(null);
  const [tempSearchNombre, setTempSearchNombre] = useState('');
  const [tempSortByStars, setTempSortByStars] = useState('');
  const [tempFechaDesde, setTempFechaDesde] = useState('');
  const [tempFechaHasta, setTempFechaHasta] = useState('');
  
  // Otros estados
  const [selectedReceta, setSelectedReceta] = useState(null);
  const [openReceta, setOpenReceta] = useState(false);
  const [authPromptOpen, setAuthPromptOpen] = useState(false);
  const [ratingDialogOpen, setRatingDialogOpen] = useState(false);
  const [ratingRecetaId, setRatingRecetaId] = useState(null);
  const [ratingRecetaNombre, setRatingRecetaNombre] = useState('');
  const [userInteractions, setUserInteractions] = useState({ likes: new Set(), favoritos: new Set(), estrellas: new Map() });
  const [modalStats, setModalStats] = useState({ likesCount: 0, avgStars: 0, totalStars: 0 });
  const [comentarios, setComentarios] = useState([]);
  const [newComentario, setNewComentario] = useState('');
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const perPage = 20;

  useEffect(()=>{
    setLoading(true);
    Promise.all([getRecetasByPais(id), getPais(id)])
      .then(([rRecetas, rPais])=>{
        const data = rRecetas && rRecetas.data ? rRecetas.data : rRecetas;
        const list = Array.isArray(data) ? data : (Array.isArray(data?.recetas) ? data.recetas : (Array.isArray(data?.items) ? data.items : []));
        setRecetas(list);
        setPais(rPais && rPais.data ? rPais.data : null);
        setError(null);
        
        if(sortByStars) {
          loadAllRecetasStars(list);
        }
        
        if(isAuthenticated()) {
          loadUserInteractions();
        }
      })
      .catch(err=>{
        setError('Error cargando recetas o país');
        setRecetas([]);
        setPais(null);
      })
      .finally(()=>{
        setLoading(false);
      });
  }, [id, sortByStars]);

  useEffect(() => {
    getPaises()
      .then(res => {
        const paisesData = res?.data || res;
        const list = Array.isArray(paisesData) ? paisesData : (Array.isArray(paisesData?.paises) ? paisesData.paises : []);
        setPaises(list);
      })
      .catch(() => setPaises([]));
  }, []);

  const loadAllRecetasStars = async (recetasList) => {
    const promises = recetasList.map(r => {
      const recetaId = r.idReceta || r.id;
      return getEstrellaStats(recetaId)
        .then(res => {
          const data = res?.data || res;
          return { id: recetaId, avg: data?.promedio || data?.average || data?.avg || 0 };
        })
        .catch(() => ({ id: recetaId, avg: 0 }));
    });
    
    const results = await Promise.all(promises);
    const newMap = new Map();
    results.forEach(r => newMap.set(r.id, r.avg));
    setRecetasWithStars(newMap);
  };

  const loadUserInteractions = async () => {
    try {
      const [favRes, likesRes, starsRes] = await Promise.all([
        getFavoritos().catch(() => ({ data: [] })),
        getMeGustas().catch(() => ({ data: [] })),
        getEstrellas().catch(() => ({ data: [] }))
      ]);
      
      const favData = favRes?.data || favRes;
      const likesData = likesRes?.data || likesRes;
      const starsData = starsRes?.data || starsRes;
      
      const favList = Array.isArray(favData) ? favData : (Array.isArray(favData?.favoritos) ? favData.favoritos : []);
      const likesList = Array.isArray(likesData) ? likesData : (Array.isArray(likesData?.likes) ? likesData.likes : []);
      const starsList = Array.isArray(starsData) ? starsData : (Array.isArray(starsData?.estrellas) ? starsData.estrellas : []);
      
      const favSet = new Set(favList.map(f => f.idReceta || f.receta_id || f.receta?.idReceta || f.receta?.id));
      const likesSet = new Set(likesList.map(l => l.idReceta || l.receta_id || l.receta?.idReceta || l.receta?.id));
      
      // Almacenar solo el valor de estrellas (simple)
      const starsMap = new Map();
      starsList.forEach(s => {
        const recetaId = s.idReceta || s.receta_id || s.id_receta || s.receta?.idReceta || s.receta?.id;
        const valor = s.estrellas || s.valor || s.valorEstrellas || s.value || 5;
        if(recetaId) starsMap.set(recetaId, valor);
      });
      
      setUserInteractions({ favoritos: favSet, likes: likesSet, estrellas: starsMap });
    } catch(e) {
      // Error silencioso
    }
  };

  const handleLike = async (recetaId) => {
    if(!isAuthenticated()) {
      setAuthPromptOpen(true);
      return;
    }
    
    const hasLike = userInteractions.likes.has(recetaId);
    const newLikes = new Set(userInteractions.likes);
    
    if(hasLike) {
      newLikes.delete(recetaId);
      await deleteLikeReceta(recetaId).catch(()=>{});
    } else {
      newLikes.add(recetaId);
      await postLikeReceta(recetaId).catch(()=>{});
    }
    
    setUserInteractions(prev => ({ ...prev, likes: newLikes }));
    
    if(selectedReceta && (selectedReceta.idReceta === recetaId || selectedReceta.id === recetaId)) {
      loadModalStats(recetaId);
    }
  };

  const handleFavorito = async (recetaId) => {
    if(!isAuthenticated()) {
      setAuthPromptOpen(true);
      return;
    }
    
    const hasFav = userInteractions.favoritos.has(recetaId);
    const newFavs = new Set(userInteractions.favoritos);
    
    if(hasFav) {
      newFavs.delete(recetaId);
      await deleteFavoritoReceta(recetaId).catch(()=>{});
    } else {
      newFavs.add(recetaId);
      await postFavoritoReceta(recetaId).catch(()=>{});
    }
    
    setUserInteractions(prev => ({ ...prev, favoritos: newFavs }));
  };

  const handleOpenRating = (recetaId, nombre) => {
    if(!isAuthenticated()) {
      setAuthPromptOpen(true);
      return;
    }
    setRatingRecetaId(recetaId);
    setRatingRecetaNombre(nombre);
    setRatingDialogOpen(true);
  };

  const handleRatingSubmit = async (valor) => {
    if(!ratingRecetaId) return;
    
    try {
      await postStarReceta(ratingRecetaId, valor);
      const newStars = new Map(userInteractions.estrellas);
      newStars.set(ratingRecetaId, valor);
      setUserInteractions(prev => ({ ...prev, estrellas: newStars }));
      
      if(selectedReceta && (selectedReceta.idReceta === ratingRecetaId || selectedReceta.id === ratingRecetaId)) {
        loadModalStats(ratingRecetaId);
      }
      
      if(sortByStars) {
        loadAllRecetasStars(recetas);
      }
    } catch(e) {
      // Error silencioso
    }
  };

  const handleDeleteRating = async () => {
    if(!ratingRecetaId) return;
    
    try {
      const estrellaActual = userInteractions.estrellas.get(ratingRecetaId);
      if(estrellaActual) {
        // Obtener todas las estrellas del usuario para encontrar el idEstrella
        const estrellasRes = await getEstrellas();
        const estrellasData = estrellasRes?.data || estrellasRes || [];
        const starsList = Array.isArray(estrellasData) ? estrellasData : (Array.isArray(estrellasData?.estrellas) ? estrellasData.estrellas : []);
        
        const miEstrella = starsList.find(e => {
          const recetaId = e.idReceta || e.receta_id || e.id_receta || e.receta?.idReceta || e.receta?.id;
          return recetaId === ratingRecetaId;
        });
        
        if(miEstrella && (miEstrella.idEstrella || miEstrella.id)) {
          await deleteStarReceta(miEstrella.idEstrella || miEstrella.id);
          const newStars = new Map(userInteractions.estrellas);
          newStars.delete(ratingRecetaId);
          setUserInteractions(prev => ({ ...prev, estrellas: newStars }));
          
          if(selectedReceta && (selectedReceta.idReceta === ratingRecetaId || selectedReceta.id === ratingRecetaId)) {
            loadModalStats(ratingRecetaId);
          }
          
          if(sortByStars) {
            loadAllRecetasStars(recetas);
          }
        }
      }
    } catch(e) {
      // Error silencioso
    }
  };

  const loadComentarios = async (recetaId) => {
    if(!recetaId) return;
    try {
      const res = await getComentariosReceta(recetaId);
      const data = res?.data || res;
      const list = Array.isArray(data) ? data : (Array.isArray(data?.comentarios) ? data.comentarios : []);
      
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
            return {
              ...comentario,
              nombreUsuario: 'Usuario'
            };
          }
        })
      );
      
      setComentarios(comentariosConNombres);
    } catch(e) {
      setComentarios([]);
    }
  };

  const handleEnviarComentario = async () => {
    if(!isAuthenticated()) {
      setAuthPromptOpen(true);
      return;
    }
    
    if(!newComentario.trim() || !selectedReceta) return;
    
    const recetaId = selectedReceta?.idReceta || selectedReceta?.id;
    
    try {
      await postComentarioReceta(recetaId, newComentario);
      setNewComentario('');
      loadComentarios(recetaId);
    } catch(e) {
      // Error silencioso
    }
  };

  // Filtros aplicados
  const filteredRecetas = recetas.filter(r => {
    const matchSearch = search ? r.nombre?.toLowerCase().includes(search.toLowerCase()) : true;
    const matchPais = selectedPais ? (r.idPais === selectedPais.idPais || r.pais_id === selectedPais.idPais) : true;
    const matchNombre = searchNombre ? r.nombre?.toLowerCase().includes(searchNombre.toLowerCase()) : true;
    
    let matchFecha = true;
    if(fechaDesde || fechaHasta) {
      const recetaFecha = new Date(r.fechaCreacion || r.fecha_creacion);
      if(fechaDesde) {
        const desde = new Date(fechaDesde);
        if(recetaFecha < desde) matchFecha = false;
      }
      if(fechaHasta) {
        const hasta = new Date(fechaHasta);
        if(recetaFecha > hasta) matchFecha = false;
      }
    }
    
    return matchSearch && matchPais && matchNombre && matchFecha;
  });

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
    setModalStats({ likesCount: 0, avgStars: 0, totalStars: 0 });
  };

  const loadModalStats = async (recetaId) => {
    if(!recetaId) return;
    try {
      const [likesRes, starsRes] = await Promise.all([
        getMeGustaCount(recetaId).catch(() => ({ data: { count: 0 } })),
        getEstrellaStats(recetaId).catch(() => ({ data: { promedio: 0, total: 0 } }))
      ]);
      
      const likesData = likesRes?.data || likesRes;
      const starsData = starsRes?.data || starsRes;
      
      setModalStats({
        likesCount: likesData?.count || likesData?.total || 0,
        avgStars: starsData?.promedio || starsData?.average || starsData?.avg || 0,
        totalStars: starsData?.total || starsData?.count || 0
      });
    } catch(e) {
      // Error silencioso
    }
  };

  const handleApplyFilters = () => {
    setSelectedPais(tempSelectedPais);
    setSearchNombre(tempSearchNombre);
    setSortByStars(tempSortByStars);
    setFechaDesde(tempFechaDesde);
    setFechaHasta(tempFechaHasta);
    setFilterDrawerOpen(false);
    setPage(1);
  };

  const handleResetFilters = () => {
    setTempSelectedPais(null);
    setTempSearchNombre('');
    setTempSortByStars('');
    setTempFechaDesde('');
    setTempFechaHasta('');
    setSelectedPais(null);
    setSearchNombre('');
    setSortByStars('');
    setFechaDesde('');
    setFechaHasta('');
    setPage(1);
  };
  
  const handleOpenFilterDrawer = () => {
    setTempSelectedPais(selectedPais);
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
              {pais ? pais.nombre : 'País'}
            </Typography>
            {pais && (
              <Typography sx={{
                color: 'white',
                fontFamily: 'Open Sans, sans-serif',
                fontWeight: 600,
                fontSize: { xs: '0.95rem', sm: '1rem', md: '1.1rem' },
                mt: 1,
                textShadow: '1px 1px 2px rgba(0,0,0,0.1)'
              }}>
                Descubre recetas de esta categoría
              </Typography>
            )}
          </Box>
        </Container>
      </Box>

      <Container maxWidth="xl" sx={{ py: { xs: 3, md: 5 }, px: 2, mx: 'auto' }}>
        {loading && <Typography sx={{ textAlign: 'center', color: '#667EEA', fontFamily: 'Open Sans, sans-serif' }}>Cargando...</Typography>}
        {error && <Typography color="error" sx={{ textAlign: 'center' }}>{error}</Typography>}
        
        <Box sx={{ mb: 3, display: 'flex', justifyContent: 'flex-start', gap: 2, alignItems: 'center', flexWrap: 'wrap' }}>
          <Button 
            variant="contained" 
            startIcon={<FilterListIcon />} 
            onClick={handleOpenFilterDrawer}
            size="medium"
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
          <TextField 
            size="small" 
            placeholder="Buscar en estas recetas..." 
            value={search} 
            onChange={(e)=>{ setSearch(e.target.value); setPage(1); }} 
            sx={{ 
              minWidth: 300,
              '& .MuiOutlinedInput-root': {
                borderRadius: 50,
                backgroundColor: 'white'
              }
            }}
          />
        </Box>

        {/* SECCIÓN DE TARJETAS RECREADA DESDE CERO */}
        <Grid container spacing={3} columns={12}>
          {recetas.length === 0 && !loading && (
            <Grid item xs={12}>
              <Box sx={{
                textAlign: 'center',
                py: 6,
                backgroundColor: '#F7FAFC',
                borderRadius: 3
              }}>
                <Typography sx={{ 
                  color: '#718096', 
                  fontFamily: 'Open Sans, sans-serif', 
                  fontSize: { xs: '1rem', md: '1.1rem' }
                }}>
                  No se encontraron recetas para esta categoría.
                </Typography>
              </Box>
            </Grid>
          )}
          
          {sortedRecetas.slice((page-1)*perPage, page*perPage).map(r => {
            const recetaId = r.idReceta || r.id;
            return (
              <Grid 
                item 
                key={recetaId} 
                xs={6}
                sx={{
                  maxWidth: 'calc(50% - 12px)',
                  flexBasis: 'calc(50% - 12px)',
                  flexGrow: 0,
                  flexShrink: 0
                }}
              >
                <Box sx={{ 
                  backgroundColor: 'white',
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
                            backgroundColor: userInteractions.likes.has(recetaId) ? '#4299E1' : '#F7FAFC',
                            color: userInteractions.likes.has(recetaId) ? 'white' : '#4299E1',
                            '&:hover': {
                              backgroundColor: '#4299E1',
                              color: 'white'
                            }
                          }}
                        >
                          {userInteractions.likes.has(recetaId) ? <ThumbUpIcon fontSize="small" /> : <ThumbUpOutlinedIcon fontSize="small" />}
                        </IconButton>
                        <IconButton 
                          size="small" 
                          onClick={() => handleOpenRating(recetaId, r.nombre)} 
                          aria-label="star"
                          sx={{
                            backgroundColor: userInteractions.estrellas.has(recetaId) ? '#ED8936' : '#F7FAFC',
                            color: userInteractions.estrellas.has(recetaId) ? 'white' : '#ED8936',
                            '&:hover': {
                              backgroundColor: '#ED8936',
                              color: 'white'
                            }
                          }}
                        >
                          {userInteractions.estrellas.has(recetaId) ? <StarIcon fontSize="small" /> : <StarBorderIcon fontSize="small" />}
                        </IconButton>
                        <IconButton 
                          size="small" 
                          onClick={() => handleFavorito(recetaId)} 
                          aria-label="fav"
                          sx={{
                            backgroundColor: userInteractions.favoritos.has(recetaId) ? '#F56565' : '#F7FAFC',
                            color: userInteractions.favoritos.has(recetaId) ? 'white' : '#F56565',
                            '&:hover': {
                              backgroundColor: '#F56565',
                              color: 'white'
                            }
                          }}
                        >
                          {userInteractions.favoritos.has(recetaId) ? <BookmarkIcon fontSize="small" /> : <BookmarkBorderIcon fontSize="small" />}
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

        {sortedRecetas.length > perPage && (
          <Box sx={{ display: 'flex', justifyContent: 'center', mt: 3 }}>
            <Pagination 
              count={Math.ceil(sortedRecetas.length / perPage)} 
              page={page} 
              onChange={(e, value) => setPage(value)} 
              color="primary" 
            />
          </Box>
        )}

        {/* MODAL DE RECETA */}
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
            {isAdmin() && (
              <Typography component="span" sx={{ 
                ml: 2, 
                fontSize: '0.9rem', 
                color: '#718096',
                fontWeight: 400
              }}>
                (ID: {selectedReceta?.idReceta || selectedReceta?.id})
              </Typography>
            )}
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
            
            <Box sx={{ 
              backgroundColor: '#F9E9AE',
              borderRadius: 3,
              p: 2.5,
              mb: 3
            }}>
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
                      {modalStats.likesCount}
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
                      {modalStats.avgStars > 0 ? modalStats.avgStars.toFixed(1) : '0.0'}
                      <Typography component="span" variant="body2" sx={{ ml: 0.5, color: '#969696', fontWeight: 400 }}>
                        ({modalStats.totalStars})
                      </Typography>
                    </Typography>
                  </Box>
                </Box>
                
                {/* Botón Favorito a la derecha */}
                <IconButton 
                  aria-label="fav" 
                  onClick={() => handleFavorito(selectedReceta?.idReceta || selectedReceta?.id)}
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
            </Box>
            
            <Divider sx={{ my: 3 }} />
            
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
                onKeyPress={(e) => { if(e.key === 'Enter') handleEnviarComentario(); }}
                sx={{
                  '& .MuiOutlinedInput-root': {
                    borderRadius: 50,
                    borderColor: '#F75442',
                    fontFamily: 'Open Sans, sans-serif'
                  }
                }}
              />
              <Button
                variant="contained"
                onClick={handleEnviarComentario}
                sx={{
                  borderRadius: 50,
                  background: 'linear-gradient(135deg, #F75442 0%, #FA968B 100%)',
                  fontFamily: 'Open Sans, sans-serif',
                  fontWeight: 700,
                  px: 3,
                  '&:hover': {
                    background: 'linear-gradient(135deg, #FA968B 0%, #F75442 100%)'
                  }
                }}
              >
                Enviar
              </Button>
            </Box>
          </DialogContent>
          <DialogActions>
            <Button onClick={handleCloseReceta} sx={{ 
              color: '#667EEA',
              fontFamily: 'Open Sans, sans-serif',
              fontWeight: 700
            }}>
              Cerrar
            </Button>
          </DialogActions>
        </Dialog>

        {/* DRAWER DE FILTROS */}
        <Drawer
          anchor="right"
          open={filterDrawerOpen}
          onClose={() => setFilterDrawerOpen(false)}
        >
          <Box sx={{ width: 320, p: 3 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
              <Typography variant="h6" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 900 }}>
                Filtros
              </Typography>
              <IconButton onClick={() => setFilterDrawerOpen(false)}>
                <CloseIcon />
              </IconButton>
            </Box>
            
            <Typography variant="subtitle2" sx={{ mb: 1, fontFamily: 'Open Sans, sans-serif', fontWeight: 700 }}>
              Buscar por nombre
            </Typography>
            <TextField
              fullWidth
              size="small"
              placeholder="Nombre de receta..."
              value={tempSearchNombre}
              onChange={(e) => setTempSearchNombre(e.target.value)}
              sx={{ mb: 2 }}
            />
            
            <Typography variant="subtitle2" sx={{ mb: 1, fontFamily: 'Open Sans, sans-serif', fontWeight: 700 }}>
              Filtrar por país
            </Typography>
            <Autocomplete
              size="small"
              options={paises}
              getOptionLabel={(option) => option.nombre || ''}
              value={tempSelectedPais}
              onChange={(e, newValue) => setTempSelectedPais(newValue)}
              renderInput={(params) => <TextField {...params} placeholder="Selecciona un país" />}
              sx={{ mb: 2 }}
            />
            
            <Typography variant="subtitle2" sx={{ mb: 1, fontFamily: 'Open Sans, sans-serif', fontWeight: 700 }}>
              Ordenar por estrellas
            </Typography>
            <FormControl fullWidth size="small" sx={{ mb: 2 }}>
              <Select
                value={tempSortByStars}
                onChange={(e) => setTempSortByStars(e.target.value)}
                displayEmpty
              >
                <MenuItem value="">Sin orden</MenuItem>
                <MenuItem value="desc">Mayor a menor</MenuItem>
                <MenuItem value="asc">Menor a mayor</MenuItem>
              </Select>
            </FormControl>
            
            <Typography variant="subtitle2" sx={{ mb: 1, fontFamily: 'Open Sans, sans-serif', fontWeight: 700 }}>
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

        <AuthPromptDialog 
          open={authPromptOpen} 
          onClose={() => setAuthPromptOpen(false)} 
        />

        <RatingDialog
          open={ratingDialogOpen}
          onClose={() => setRatingDialogOpen(false)}
          onRate={handleRatingSubmit}
          onDelete={handleDeleteRating}
          recetaNombre={ratingRecetaNombre}
          hasRating={ratingRecetaId ? userInteractions.estrellas.has(ratingRecetaId) : false}
        />
      </Container>
    </Box>
  );
}
