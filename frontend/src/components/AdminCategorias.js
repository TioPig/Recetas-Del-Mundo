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
import { adminGetCategorias, adminCreateCategoria, adminUpdateCategoria, adminDeleteCategoria } from '../api';

function AdminCategorias() {
  const [categorias, setCategorias] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [openDialog, setOpenDialog] = useState(false);
  const [selectedCategoria, setSelectedCategoria] = useState(null);
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

  const loadCategorias = async () => {
    try {
      setLoading(true);
      const response = await adminGetCategorias();
      console.log('Respuesta categorías:', response.data);
      // La API devuelve directamente un array, no un objeto con propiedad data
      setCategorias(Array.isArray(response.data) ? response.data : (response.data?.data || []));
      setError(null);
    } catch (err) {
      console.error('Error cargando categorías:', err);
      setError('Error al cargar categorías: ' + (err.response?.data?.mensaje || err.message));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadCategorias();
  }, []);

  const handleAdd = () => {
    setSelectedCategoria(null);
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

  const handleEdit = (categoria) => {
    setSelectedCategoria(categoria);
    setFormData({
      nombre: categoria.nombre || '',
      urlImagen: categoria.urlImagen || '',
      estado: categoria.estado || 1,
      fechaCreacion: categoria.fechaCreacion,
      idUsr: categoria.idUsr,
      comentario: categoria.comentario || ''
    });
    setOpenDialog(true);
  };

  const handleDelete = async (id) => {
    if (!window.confirm('¿Estás seguro de eliminar esta categoría?')) return;
    
    try {
      const response = await adminDeleteCategoria(id);
      
      // Verificar si la respuesta indica éxito
      if (response.data?.exito === false) {
        setError(response.data?.mensaje || 'Error al eliminar categoría');
        setTimeout(() => setError(null), 5000);
        return;
      }
      
      setSuccess('Categoría eliminada correctamente');
      loadCategorias();
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      const errorMsg = err.response?.data?.mensaje || err.message;
      setError('Error al eliminar categoría: ' + errorMsg);
      setTimeout(() => setError(null), 5000);
    }
  };

  const handleSave = async () => {
    try {
      let response;
      if (selectedCategoria) {
        // Al editar, enviamos todos los campos
        response = await adminUpdateCategoria(selectedCategoria.idCat, formData);
      } else {
        // Al crear, el backend de categorías tiene un bug que no auto-genera fechaCreacion e idUsr
        // Workaround: enviamos valores por defecto desde el frontend
        const user = JSON.parse(localStorage.getItem('user') || '{}');
        const userId = user.id_usr || user.idUsr || user.id || 1;
        
        const newCategoria = {
          nombre: formData.nombre,
          urlImagen: formData.urlImagen,
          estado: formData.estado,
          comentario: '', // Enviar string vacío en lugar de null
          fechaCreacion: new Date().toISOString(), // Generar fecha actual
          idUsr: userId // Usar el ID del usuario logueado
        };
        console.log('Creando categoría con datos:', newCategoria);
        response = await adminCreateCategoria(newCategoria);
      }
      
      // Verificar si la respuesta indica éxito
      if (response.data?.exito === false) {
        setError(response.data?.mensaje || 'Error al guardar categoría');
        setTimeout(() => setError(null), 5000);
        return;
      }
      
      setSuccess(selectedCategoria ? 'Categoría actualizada correctamente' : 'Categoría creada correctamente');
      setOpenDialog(false);
      loadCategorias();
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      const errorMsg = err.response?.data?.mensaje || err.message;
      setError('Error al guardar categoría: ' + errorMsg);
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

  // Filtrar categorías según búsqueda
  const filteredCategorias = categorias.filter(categoria => {
    return searchTerm === '' || 
      categoria.nombre?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      categoria.idCat?.toString().includes(searchTerm);
  });

  const paginatedCategorias = filteredCategorias.slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage);

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
          Gestión de Categorías ({filteredCategorias.length})
        </Typography>
        <Fab color="primary" size="medium" onClick={handleAdd} title="Agregar Categoría">
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
            {paginatedCategorias.map((categoria) => (
              <TableRow key={categoria.idCat} hover>
                <TableCell>{categoria.idCat}</TableCell>
                <TableCell>{categoria.nombre}</TableCell>
                <TableCell>
                  {categoria.urlImagen && (
                    <img 
                      src={categoria.urlImagen} 
                      alt={categoria.nombre}
                      style={{ width: '50px', height: '50px', objectFit: 'cover', borderRadius: '4px' }}
                    />
                  )}
                </TableCell>
                <TableCell>
                  {categoria.estado === 1 ? 'Activo' : 'Inactivo'}
                </TableCell>
                <TableCell>{categoria.usuario?.nombre || categoria.usuario?.correo || categoria.idUsr || 'N/A'}</TableCell>
                <TableCell>
                  <IconButton 
                    size="small" 
                    color="primary" 
                    onClick={() => handleEdit(categoria)}
                    title="Editar"
                  >
                    <EditIcon />
                  </IconButton>
                  <IconButton 
                    size="small" 
                    color="error" 
                    onClick={() => handleDelete(categoria.idCat)}
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
          count={categorias.length}
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
        <DialogTitle>{selectedCategoria ? 'Editar Categoría' : 'Nueva Categoría'}</DialogTitle>
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
            {selectedCategoria ? 'Actualizar' : 'Crear'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}

export default AdminCategorias;
