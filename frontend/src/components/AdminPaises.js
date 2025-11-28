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
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  Fab,
  TablePagination
} from '@mui/material';
import {
  Edit as EditIcon,
  Delete as DeleteIcon,
  Add as AddIcon
} from '@mui/icons-material';
import SearchFilter from './SearchFilter';
import { adminGetPaises, adminCreatePais, adminUpdatePais, adminDeletePais } from '../api';

function AdminPaises() {
  const [paises, setPaises] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [openDialog, setOpenDialog] = useState(false);
  const [selectedPais, setSelectedPais] = useState(null);
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [searchTerm, setSearchTerm] = useState('');
  const [formData, setFormData] = useState({
    nombre: '',
    urlImagen: '',
    estado: 1,
    fechaCreacion: null,
    idUsr: null,
    comentario: ''
  });

  const loadPaises = async () => {
    try {
      setLoading(true);
      const response = await adminGetPaises();
      console.log('Respuesta países:', response.data);
      // La API devuelve directamente un array, no un objeto con propiedad data
      setPaises(Array.isArray(response.data) ? response.data : (response.data?.data || []));
      setError(null);
    } catch (err) {
      console.error('Error cargando países:', err);
      setError('Error al cargar países: ' + (err.response?.data?.mensaje || err.message));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadPaises();
  }, []);

  const handleAdd = () => {
    setSelectedPais(null);
    setFormData({ 
      nombre: '', 
      urlImagen: '', 
      estado: 1,
      fechaCreacion: null,
      idUsr: null,
      comentario: ''
    });
    setOpenDialog(true);
  };

  const handleEdit = (pais) => {
    setSelectedPais(pais);
    setFormData({
      nombre: pais.nombre || '',
      urlImagen: pais.urlImagen || '',
      estado: pais.estado || 1,
      fechaCreacion: pais.fechaCreacion,
      idUsr: pais.idUsr,
      comentario: pais.comentario || ''
    });
    setOpenDialog(true);
  };

  const handleDelete = async (id) => {
    if (!window.confirm('¿Estás seguro de eliminar este país?')) return;
    
    try {
      const response = await adminDeletePais(id);
      
      // Verificar si la respuesta indica éxito
      if (response.data?.exito === false) {
        setError(response.data?.mensaje || 'Error al eliminar país');
        setTimeout(() => setError(null), 5000);
        return;
      }
      
      setSuccess('País eliminado correctamente');
      loadPaises();
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      const errorMsg = err.response?.data?.mensaje || err.message;
      setError('Error al eliminar país: ' + errorMsg);
      setTimeout(() => setError(null), 5000);
    }
  };

  const handleSave = async () => {
    try {
      let response;
      if (selectedPais) {
        response = await adminUpdatePais(selectedPais.idPais, formData);
      } else {
        // Al crear, solo enviamos los campos que el usuario ingresa
        const newPais = {
          nombre: formData.nombre,
          urlImagen: formData.urlImagen,
          estado: formData.estado
        };
        response = await adminCreatePais(newPais);
      }
      
      // Verificar si la respuesta indica éxito
      if (response.data?.exito === false) {
        setError(response.data?.mensaje || 'Error al guardar país');
        setTimeout(() => setError(null), 5000);
        return;
      }
      
      setSuccess(selectedPais ? 'País actualizado correctamente' : 'País creado correctamente');
      setOpenDialog(false);
      loadPaises();
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      const errorMsg = err.response?.data?.mensaje || err.message;
      setError('Error al guardar país: ' + errorMsg);
      setTimeout(() => setError(null), 5000);
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  // Filtrar países según búsqueda
  const filteredPaises = paises.filter(pais => {
    return searchTerm === '' || 
      pais.nombre?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      pais.idPais?.toString().includes(searchTerm);
  });

  const paginatedPaises = filteredPaises.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage);

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h5" sx={{ fontWeight: 'bold' }}>
          Gestión de Países ({filteredPaises.length})
        </Typography>
        <Fab color="primary" size="medium" onClick={handleAdd} title="Agregar País">
          <AddIcon />
        </Fab>
      </Box>

      {error && <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError(null)}>{error}</Alert>}
      {success && <Alert severity="success" sx={{ mb: 2 }} onClose={() => setSuccess(null)}>{success}</Alert>}

      <SearchFilter
        searchValue={searchTerm}
        onSearchChange={(e) => setSearchTerm(e.target.value)}
        searchPlaceholder="Buscar por nombre o ID..."
        showFilter={false}
      />

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow sx={{ backgroundColor: 'primary.main' }}>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>ID</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Nombre</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Imagen</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Estado</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Usuario</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Acciones</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {paginatedPaises.map((pais) => (
              <TableRow key={pais.idPais} hover>
                <TableCell>{pais.idPais}</TableCell>
                <TableCell>{pais.nombre}</TableCell>
                <TableCell>
                  {pais.urlImagen && (
                    <img 
                      src={pais.urlImagen} 
                      alt={pais.nombre}
                      style={{ width: '50px', height: '30px', objectFit: 'cover', borderRadius: '4px' }}
                    />
                  )}
                </TableCell>
                <TableCell>
                  {pais.estado === 1 ? 'Activo' : 'Inactivo'}
                </TableCell>
                <TableCell>{pais.usuario?.nombre || pais.usuario?.correo || pais.idUsr || 'N/A'}</TableCell>
                <TableCell>
                  <IconButton 
                    size="small" 
                    color="primary" 
                    onClick={() => handleEdit(pais)}
                    title="Editar"
                  >
                    <EditIcon />
                  </IconButton>
                  <IconButton 
                    size="small" 
                    color="error" 
                    onClick={() => handleDelete(pais.idPais)}
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
          count={paises.length}
          page={page}
          onPageChange={handleChangePage}
          rowsPerPage={rowsPerPage}
          onRowsPerPageChange={handleChangeRowsPerPage}
          rowsPerPageOptions={[5, 10, 25, 50]}
          labelRowsPerPage="Filas por página:"
          labelDisplayedRows={({ from, to, count }) => `${from}-${to} de ${count}`}
        />
      </TableContainer>

      {/* Dialog para crear/editar */}
      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} maxWidth="sm" fullWidth>
        <DialogTitle>{selectedPais ? 'Editar País' : 'Nuevo País'}</DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, mt: 2 }}>
            <TextField
              label="Nombre"
              name="nombre"
              value={formData.nombre}
              onChange={handleChange}
              fullWidth
              required
            />
            <TextField
              label="URL de Imagen"
              name="urlImagen"
              value={formData.urlImagen}
              onChange={handleChange}
              fullWidth
            />
            <TextField
              label="Estado"
              name="estado"
              type="number"
              value={formData.estado}
              onChange={handleChange}
              fullWidth
              select
              SelectProps={{ native: true }}
            >
              <option value={1}>Activo</option>
              <option value={0}>Inactivo</option>
            </TextField>
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenDialog(false)}>Cancelar</Button>
          <Button onClick={handleSave} variant="contained" color="primary">
            {selectedPais ? 'Actualizar' : 'Crear'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}

export default AdminPaises;
