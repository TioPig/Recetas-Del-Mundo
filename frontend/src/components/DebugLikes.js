import React, { useEffect, useState } from 'react';
import { Container, Box, Typography, Button, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow } from '@mui/material';
import { getMeGustas } from '../api';

export default function DebugLikes() {
  const [allLikes, setAllLikes] = useState([]);
  const [receta1Likes, setReceta1Likes] = useState([]);
  const [currentUser, setCurrentUser] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    // Obtener usuario actual
    const user = JSON.parse(localStorage.getItem('user') || '{}');
    setCurrentUser(user);
  }, []);

  const loadLikes = async () => {
    setLoading(true);
    try {
      const response = await getMeGustas();
      const likesData = response && response.data ? response.data : response;
      const likesList = Array.isArray(likesData) ? likesData : [];
      
      setAllLikes(likesList);
      
      // Filtrar solo los likes de la receta 1
      const receta1 = likesList.filter(like => {
        const recetaId = like.idReceta || like.id_receta || like.receta?.idReceta || like.receta?.id;
        return recetaId === 1;
      });
      
      setReceta1Likes(receta1);
    } catch (error) {
      console.error('Error cargando likes:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container sx={{ py: 4 }}>
      <Typography variant="h3" gutterBottom>🔍 Debug Likes - Receta 1</Typography>
      
      <Paper sx={{ p: 2, mb: 3 }}>
        <Typography variant="h6">Usuario Actual:</Typography>
        <Typography>ID: {currentUser?.id_usr || currentUser?.idUsr || currentUser?.id || 'N/A'}</Typography>
        <Typography>Nombre: {currentUser?.nombre || 'N/A'}</Typography>
        <Typography>Email: {currentUser?.email || 'N/A'}</Typography>
      </Paper>

      <Button variant="contained" onClick={loadLikes} disabled={loading} sx={{ mb: 3 }}>
        {loading ? 'Cargando...' : 'Cargar Likes de la Receta 1'}
      </Button>

      {receta1Likes.length > 0 && (
        <Box sx={{ mb: 3 }}>
          <Typography variant="h5" gutterBottom>
            Likes en la Receta 1: {receta1Likes.length}
          </Typography>
          
          <TableContainer component={Paper}>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell><strong>ID Me Gusta</strong></TableCell>
                  <TableCell><strong>ID Usuario</strong></TableCell>
                  <TableCell><strong>Nombre Usuario</strong></TableCell>
                  <TableCell><strong>Email Usuario</strong></TableCell>
                  <TableCell><strong>ID Receta</strong></TableCell>
                  <TableCell><strong>Fecha Creación</strong></TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {receta1Likes.map((like, index) => {
                  const userId = like.usuario?.idUsr || like.usuario?.id || like.idUsuario || like.idUsr;
                  const userName = like.usuario?.nombre || 'N/A';
                  const userEmail = like.usuario?.email || 'N/A';
                  const recetaId = like.idReceta || like.id_receta || like.receta?.idReceta || like.receta?.id;
                  const currentUserId = currentUser?.id_usr || currentUser?.idUsr || currentUser?.id;
                  const isCurrentUser = userId === currentUserId;
                  
                  return (
                    <TableRow 
                      key={like.idMeGusta || index}
                      sx={{ 
                        backgroundColor: isCurrentUser ? '#e3f2fd' : 'transparent',
                        fontWeight: isCurrentUser ? 'bold' : 'normal'
                      }}
                    >
                      <TableCell>{like.idMeGusta || 'N/A'}</TableCell>
                      <TableCell>{userId || 'N/A'}</TableCell>
                      <TableCell>{userName}</TableCell>
                      <TableCell>{userEmail}</TableCell>
                      <TableCell>{recetaId}</TableCell>
                      <TableCell>{like.fechaCreacion || 'N/A'}</TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </TableContainer>
        </Box>
      )}

      {allLikes.length > 0 && (
        <Box>
          <Typography variant="h6" gutterBottom>
            Estadísticas Generales
          </Typography>
          <Typography>Total de likes en el sistema: {allLikes.length}</Typography>
          <Typography>Likes en receta 1: {receta1Likes.length}</Typography>
        </Box>
      )}

      {!loading && receta1Likes.length === 0 && allLikes.length > 0 && (
        <Typography color="warning.main">
          No hay likes en la receta 1
        </Typography>
      )}
    </Container>
  );
}
