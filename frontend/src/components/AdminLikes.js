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
  Alert,
  CircularProgress,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button
} from '@mui/material';
import {
  Delete as DeleteIcon,
  Visibility as VisibilityIcon,
  ThumbUp as ThumbUpIcon
} from '@mui/icons-material';
import { 
  adminGetAllMeGusta, 
  adminDeleteMeGusta,
  getRecetaNombre,
  getUserNombre,
  formatFecha
} from '../api';

function AdminLikes() {
  const [likes, setLikes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [openDialog, setOpenDialog] = useState(false);
  const [selectedLike, setSelectedLike] = useState(null);
  const [likesDetails, setLikesDetails] = useState({});

  const loadLikes = async () => {
    try {
      setLoading(true);
      const response = await adminGetAllMeGusta();
      const likesList = response.data || [];
      setLikes(likesList);
      
      // Cargar detalles de recetas y usuarios
      const detailsPromises = likesList.map(async (like) => {
        try {
          const [recetaRes, usuarioRes] = await Promise.all([
            getRecetaNombre(like.idReceta).catch(() => ({ data: { nombre: 'Receta eliminada' } })),
            getUserNombre(like.idUsuario).catch(() => ({ data: { nombre: 'Usuario eliminado' } }))
          ]);
          
          return {
            idMeGusta: like.idMeGusta,
            recetaNombre: recetaRes.data?.nombre || 'Receta eliminada',
            usuarioNombre: usuarioRes.data?.nombre || 'Usuario eliminado'
          };
        } catch {
          return {
            idMeGusta: like.idMeGusta,
            recetaNombre: 'Desconocido',
            usuarioNombre: 'Desconocido'
          };
        }
      });
      
      const details = await Promise.all(detailsPromises);
      const detailsMap = {};
      details.forEach(detail => {
        detailsMap[detail.idMeGusta] = detail;
      });
      setLikesDetails(detailsMap);
      
      setError(null);
    } catch (err) {
      setError('Error al cargar likes: ' + (err.response?.data?.mensaje || err.message));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadLikes();
  }, []);

  const handleView = (like) => {
    setSelectedLike(like);
    setOpenDialog(true);
  };

  const handleDelete = async (id) => {
    if (!window.confirm('¿Estás seguro de eliminar este like?')) return;
    
    try {
      const response = await adminDeleteMeGusta(id);
      
      if (response.data?.exito === false) {
        setError(response.data?.mensaje || 'Error al eliminar like');
        setTimeout(() => setError(null), 5000);
        return;
      }
      
      setSuccess('Like eliminado correctamente');
      loadLikes();
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      const errorMsg = err.response?.data?.mensaje || err.message;
      setError('Error al eliminar like: ' + errorMsg);
      setTimeout(() => setError(null), 5000);
    }
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
        👍 Gestión de Likes ({likes.length})
      </Typography>

      {error && <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError(null)}>{error}</Alert>}
      {success && <Alert severity="success" sx={{ mb: 2 }} onClose={() => setSuccess(null)}>{success}</Alert>}

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow sx={{ backgroundColor: 'primary.main' }}>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>ID</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Usuario</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Usuario ID</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Receta</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Receta ID</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Fecha</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Acciones</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {likes.map((like) => (
              <TableRow key={like.idMeGusta} hover>
                <TableCell>{like.idMeGusta}</TableCell>
                <TableCell>
                  <Chip 
                    label={likesDetails[like.idMeGusta]?.usuarioNombre || 'Cargando...'}
                    size="small"
                    color="primary"
                    variant="outlined"
                  />
                </TableCell>
                <TableCell>{like.idUsuario}</TableCell>
                <TableCell>
                  <Chip 
                    label={likesDetails[like.idMeGusta]?.recetaNombre || 'Cargando...'}
                    size="small"
                    color="secondary"
                    variant="outlined"
                  />
                </TableCell>
                <TableCell>{like.idReceta}</TableCell>
                <TableCell>
                  <Typography variant="caption">
                    {formatFecha(like.fechaCreacion)}
                  </Typography>
                </TableCell>
                <TableCell>
                  <IconButton 
                    size="small" 
                    color="info" 
                    onClick={() => handleView(like)}
                    title="Ver detalles"
                  >
                    <VisibilityIcon />
                  </IconButton>
                  <IconButton 
                    size="small" 
                    color="error" 
                    onClick={() => handleDelete(like.idMeGusta)}
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
      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} maxWidth="sm" fullWidth>
        <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <ThumbUpIcon color="primary" />
          Detalles del Like
        </DialogTitle>
        <DialogContent>
          {selectedLike && (
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, mt: 2 }}>
              <Box>
                <Typography variant="caption" color="text.secondary">ID Like</Typography>
                <Typography variant="h6">{selectedLike.idMeGusta}</Typography>
              </Box>
              <Box>
                <Typography variant="caption" color="text.secondary">Usuario</Typography>
                <Typography variant="body1">
                  {likesDetails[selectedLike.idMeGusta]?.usuarioNombre || 'Cargando...'}
                  <Typography component="span" variant="caption" color="text.secondary" sx={{ ml: 1 }}>
                    (ID: {selectedLike.idUsuario})
                  </Typography>
                </Typography>
              </Box>
              <Box>
                <Typography variant="caption" color="text.secondary">Receta</Typography>
                <Typography variant="body1">
                  {likesDetails[selectedLike.idMeGusta]?.recetaNombre || 'Cargando...'}
                  <Typography component="span" variant="caption" color="text.secondary" sx={{ ml: 1 }}>
                    (ID: {selectedLike.idReceta})
                  </Typography>
                </Typography>
              </Box>
              <Box>
                <Typography variant="caption" color="text.secondary">Fecha de creación</Typography>
                <Typography variant="body1">{formatFecha(selectedLike.fechaCreacion)}</Typography>
              </Box>
            </Box>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenDialog(false)}>Cerrar</Button>
          <Button 
            onClick={() => {
              handleDelete(selectedLike.idMeGusta);
              setOpenDialog(false);
            }} 
            color="error"
            variant="outlined"
          >
            Eliminar
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}

export default AdminLikes;
