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
  MenuItem
} from '@mui/material';
import {
  Edit as EditIcon,
  Delete as DeleteIcon,
  CheckCircle as CheckCircleIcon,
  Cancel as CancelIcon
} from '@mui/icons-material';
import { adminGetUsuarios, adminUpdateUsuario, adminDeleteUsuario, formatFecha } from '../api';

function AdminUsuarios() {
  const [usuarios, setUsuarios] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [openDialog, setOpenDialog] = useState(false);
  const [selectedUsuario, setSelectedUsuario] = useState(null);
  const [formData, setFormData] = useState({
    nombre: '',
    apellido: '',
    correo: '',
    rol: 'USER',
    estado: 1
  });

  const loadUsuarios = async () => {
    try {
      setLoading(true);
      const response = await adminGetUsuarios();
      setUsuarios(response.data || []);
      setError(null);
    } catch (err) {
      setError('Error al cargar usuarios: ' + (err.response?.data?.mensaje || err.message));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadUsuarios();
  }, []);

  const handleEdit = (usuario) => {
    setSelectedUsuario(usuario);
    setFormData({
      nombre: usuario.nombre || '',
      apellido: usuario.apellido || '',
      correo: usuario.email || '',
      rol: usuario.perfil?.nombre || 'USER',
      estado: usuario.estado !== undefined ? usuario.estado : 1
    });
    setOpenDialog(true);
  };

  const handleDelete = async (id) => {
    if (!window.confirm('¿Estás seguro de eliminar este usuario?')) return;
    
    try {
      const response = await adminDeleteUsuario(id);
      
      // Verificar si la respuesta indica éxito
      if (response.data?.exito === false) {
        setError(response.data?.mensaje || 'Error al eliminar usuario');
        setTimeout(() => setError(null), 5000);
        return;
      }
      
      setSuccess('Usuario eliminado correctamente');
      loadUsuarios();
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      const errorMsg = err.response?.data?.mensaje || err.message;
      setError('Error al eliminar usuario: ' + errorMsg);
      setTimeout(() => setError(null), 5000);
    }
  };

  const handleSave = async () => {
    if (!selectedUsuario) return;
    
    try {
      // Mapear el nombre del campo correo a email para el backend
      const dataToSend = {
        ...formData,
        email: formData.correo
      };
      delete dataToSend.correo;
      
      const response = await adminUpdateUsuario(selectedUsuario.idUsr, dataToSend);
      
      // Verificar si la respuesta indica éxito
      if (response.data?.exito === false) {
        setError(response.data?.mensaje || 'Error al actualizar usuario');
        setTimeout(() => setError(null), 5000);
        return;
      }
      
      setSuccess('Usuario actualizado correctamente');
      setOpenDialog(false);
      loadUsuarios();
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      const errorMsg = err.response?.data?.mensaje || err.message;
      setError('Error al actualizar usuario: ' + errorMsg);
      setTimeout(() => setError(null), 5000);
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: name === 'estado' ? parseInt(value) : value
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
        Gestión de Usuarios ({usuarios.length})
      </Typography>

      {error && <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError(null)}>{error}</Alert>}
      {success && <Alert severity="success" sx={{ mb: 2 }} onClose={() => setSuccess(null)}>{success}</Alert>}

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow sx={{ backgroundColor: 'primary.main' }}>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>ID</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Nombre</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Apellido</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Correo</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Rol</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Estado</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Fecha Registro</TableCell>
              <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>Acciones</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {usuarios.map((usuario) => (
              <TableRow key={usuario.idUsr} hover>
                <TableCell>{usuario.idUsr}</TableCell>
                <TableCell>{usuario.nombre}</TableCell>
                <TableCell>{usuario.apellido}</TableCell>
                <TableCell>{usuario.email}</TableCell>
                <TableCell>
                  <Chip 
                    label={usuario.perfil?.nombre || 'USER'} 
                    color={usuario.perfil?.nombre === 'ADMIN' ? 'error' : usuario.perfil?.nombre === 'LIDER' ? 'warning' : 'primary'}
                    size="small"
                  />
                </TableCell>
                <TableCell>
                  {usuario.estado === 1 ? (
                    <Chip icon={<CheckCircleIcon />} label="Activo" color="success" size="small" />
                  ) : (
                    <Chip icon={<CancelIcon />} label="Inactivo" color="default" size="small" />
                  )}
                </TableCell>
                <TableCell>
                  <Typography variant="caption">
                    {formatFecha(usuario.fechaCreacion)}
                  </Typography>
                </TableCell>
                <TableCell>
                  <IconButton 
                    size="small" 
                    color="primary" 
                    onClick={() => handleEdit(usuario)}
                    title="Editar"
                  >
                    <EditIcon />
                  </IconButton>
                  <IconButton 
                    size="small" 
                    color="error" 
                    onClick={() => handleDelete(usuario.idUsr)}
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

      {/* Dialog para editar */}
      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} maxWidth="sm" fullWidth>
        <DialogTitle>
          Editar Usuario
          {selectedUsuario && (
            <Typography variant="caption" display="block" color="text.secondary">
              ID: {selectedUsuario.idUsr} | Perfil ID: {selectedUsuario.perfil?.idPerfil} | 
              Registrado: {formatFecha(selectedUsuario.fechaCreacion)}
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
              label="Apellido"
              name="apellido"
              value={formData.apellido}
              onChange={handleChange}
              fullWidth
            />
            <TextField
              label="Correo"
              name="correo"
              value={formData.correo}
              onChange={handleChange}
              fullWidth
              type="email"
            />
            <TextField
              select
              label="Rol"
              name="rol"
              value={formData.rol}
              onChange={handleChange}
              fullWidth
            >
              <MenuItem value="USER">USER</MenuItem>
              <MenuItem value="LIDER">LIDER</MenuItem>
              <MenuItem value="ADMIN">ADMIN</MenuItem>
            </TextField>
            <TextField
              select
              label="Estado"
              name="estado"
              value={formData.estado}
              onChange={handleChange}
              fullWidth
            >
              <MenuItem value={1}>Activo</MenuItem>
              <MenuItem value={0}>Inactivo</MenuItem>
            </TextField>
          </Box>
          {selectedUsuario?.comentario && (
            <Alert severity="info" sx={{ mx: 3, mb: 2 }}>
              <strong>Comentario de registro:</strong> {selectedUsuario.comentario}
            </Alert>
          )}
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

export default AdminUsuarios;
