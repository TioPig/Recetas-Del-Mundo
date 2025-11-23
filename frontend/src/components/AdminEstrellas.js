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
  Button,
  Rating
} from '@mui/material';
import {
  Delete as DeleteIcon,
  Visibility as VisibilityIcon,
  Star as StarIcon
} from '@mui/icons-material';
import { 
  adminGetAllEstrellas, 
  adminDeleteEstrella,
  getRecetaNombre,
  getUserNombre,
  formatFecha
} from '../api';

function AdminEstrellas() {
  const [estrellas, setEstrellas] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [openDialog, setOpenDialog] = useState(false);
  const [selectedEstrella, setSelectedEstrella] = useState(null);
  const [estrellasDetails, setEstrellasDetails] = useState({});

  const loadEstrellas = async () => {
    try {
      setLoading(true);
      const response = await adminGetAllEstrellas();
      const estrellasList = response.data || [];
      setEstrellas(estrellasList);
      
      // Cargar detalles de recetas y usuarios
      const detailsPromises = estrellasList.map(async (estrella) => {
        try {
          const [recetaRes, usuarioRes] = await Promise.all([
            getRecetaNombre(estrella.idReceta).catch(() => ({ data: { nombre: 'Receta eliminada' } })),
            getUserNombre(estrella.idUsuario).catch(() => ({ data: { nombre: 'Usuario eliminado' } }))
          ]);
          
          return {
            idEstrella: estrella.idEstrella,
            recetaNombre: recetaRes.data?.nombre || 'Receta eliminada',
            usuarioNombre: usuarioRes.data?.nombre || 'Usuario eliminado'
          };
        } catch {
          return {
            idEstrella: estrella.idEstrella,
            recetaNombre: 'Desconocido',
            usuarioNombre: 'Desconocido'
          };
        }
      });
      
      const details = await Promise.all(detailsPromises);
      const detailsMap = {};
      details.forEach(detail => {
        detailsMap[detail.idEstrella] = detail;
      });
      setEstrellasDetails(detailsMap);
      
      setError(null);
    } catch (err) {
      setError('Error al cargar calificaciones: ' + (err.response?.data?.mensaje || err.message));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadEstrellas();
  }, []);

  const handleView = (estrella) => {
    setSelectedEstrella(estrella);
    setOpenDialog(true);
  };

  const handleDelete = async (id) => {
    if (!window.confirm('¿Estás seguro de eliminar esta calificación?')) return;
    
    try {
      const response = await adminDeleteEstrella(id);
      
      if (response.data?.exito === false) {
        setError(response.data?.mensaje || 'Error al eliminar calificación');
        setTimeout(() => setError(null), 5000);
        return;
      }
      
      setSuccess('Calificación eliminada correctamente');
      loadEstrellas();
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      const errorMsg = err.response?.data?.mensaje || err.message;
      setError('Error al eliminar calificación: ' + errorMsg);
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
        ⭐ Gestión de Calificaciones ({estrellas.length})
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
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Calificación</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Fecha</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Acciones</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {estrellas.map((estrella) => (
              <TableRow key={estrella.idEstrella} hover>
                <TableCell>{estrella.idEstrella}</TableCell>
                <TableCell>
                  <Chip 
                    label={estrellasDetails[estrella.idEstrella]?.usuarioNombre || 'Cargando...'}
                    size="small"
                    color="primary"
                    variant="outlined"
                  />
                </TableCell>
                <TableCell>{estrella.idUsuario}</TableCell>
                <TableCell>
                  <Chip 
                    label={estrellasDetails[estrella.idEstrella]?.recetaNombre || 'Cargando...'}
                    size="small"
                    color="secondary"
                    variant="outlined"
                  />
                </TableCell>
                <TableCell>{estrella.idReceta}</TableCell>
                <TableCell>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Rating value={estrella.estrellas} readOnly size="small" />
                    <Typography variant="caption" sx={{ fontWeight: 'bold' }}>
                      ({estrella.estrellas})
                    </Typography>
                  </Box>
                </TableCell>
                <TableCell>
                  <Typography variant="caption">
                    {formatFecha(estrella.fechaCreacion)}
                  </Typography>
                </TableCell>
                <TableCell>
                  <IconButton 
                    size="small" 
                    color="info" 
                    onClick={() => handleView(estrella)}
                    title="Ver detalles"
                  >
                    <VisibilityIcon />
                  </IconButton>
                  <IconButton 
                    size="small" 
                    color="error" 
                    onClick={() => handleDelete(estrella.idEstrella)}
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
          <StarIcon color="warning" />
          Detalles de la Calificación
        </DialogTitle>
        <DialogContent>
          {selectedEstrella && (
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, mt: 2 }}>
              <Box>
                <Typography variant="caption" color="text.secondary">ID Calificación</Typography>
                <Typography variant="h6">{selectedEstrella.idEstrella}</Typography>
              </Box>
              <Box>
                <Typography variant="caption" color="text.secondary">Usuario</Typography>
                <Typography variant="body1">
                  {estrellasDetails[selectedEstrella.idEstrella]?.usuarioNombre || 'Cargando...'}
                  <Typography component="span" variant="caption" color="text.secondary" sx={{ ml: 1 }}>
                    (ID: {selectedEstrella.idUsuario})
                  </Typography>
                </Typography>
              </Box>
              <Box>
                <Typography variant="caption" color="text.secondary">Receta</Typography>
                <Typography variant="body1">
                  {estrellasDetails[selectedEstrella.idEstrella]?.recetaNombre || 'Cargando...'}
                  <Typography component="span" variant="caption" color="text.secondary" sx={{ ml: 1 }}>
                    (ID: {selectedEstrella.idReceta})
                  </Typography>
                </Typography>
              </Box>
              <Box>
                <Typography variant="caption" color="text.secondary">Calificación</Typography>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mt: 1 }}>
                  <Rating value={selectedEstrella.estrellas} readOnly />
                  <Typography variant="h6">
                    {selectedEstrella.estrellas} / 5
                  </Typography>
                </Box>
              </Box>
              <Box>
                <Typography variant="caption" color="text.secondary">Fecha de creación</Typography>
                <Typography variant="body1">{formatFecha(selectedEstrella.fechaCreacion)}</Typography>
              </Box>
            </Box>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenDialog(false)}>Cerrar</Button>
          <Button 
            onClick={() => {
              handleDelete(selectedEstrella.idEstrella);
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

export default AdminEstrellas;
