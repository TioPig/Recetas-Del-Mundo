import React from 'react';
import { useNavigate } from 'react-router-dom';
import Drawer from '@mui/material/Drawer';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import IconButton from '@mui/material/IconButton';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import BookmarkIcon from '@mui/icons-material/Bookmark';
import MenuBookIcon from '@mui/icons-material/MenuBook';
import SettingsIcon from '@mui/icons-material/Settings';
import LogoutIcon from '@mui/icons-material/Logout';

export default function UserSidebar({ open, onClose, onLogout }){
  // read user from localStorage
  let user = null;
  try{ user = JSON.parse(localStorage.getItem('user') || 'null'); }catch(e){ user = null; }
  const navigate = useNavigate();

  const displayName = user && (user.nombre || user.name || user.firstName) ? `${user.nombre || user.name || ''} ${user.apellido || user.lastName || ''}`.trim() : (user && user.username ? user.username : 'Usuario');
  const email = user && (user.email || user.usuario || user.mail) ? (user.email || user.usuario || user.mail) : '';

  return (
    <Drawer anchor="right" open={open} onClose={onClose}>
      <Box sx={{ width: 300, p: 2 }} role="presentation">
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
          <Box component="img" src="/img/user-cheems.png" alt="avatar" sx={{ width: 64, height: 64, borderRadius: '50%' }} />
          <Box>
            <Typography variant="h6">{displayName}</Typography>
            <Typography variant="body2" color="text.secondary">{email}</Typography>
          </Box>
        </Box>

        <List>
          <ListItem disablePadding>
            <ListItemButton onClick={() => { onClose && onClose(); navigate('/mi/favoritos'); }}>
              <ListItemIcon><BookmarkIcon /></ListItemIcon>
              <ListItemText primary="Favoritos" />
            </ListItemButton>
          </ListItem>
          <ListItem disablePadding>
            <ListItemButton onClick={() => { onClose && onClose(); navigate('/mi/recetas'); }}>
              <ListItemIcon><MenuBookIcon /></ListItemIcon>
              <ListItemText primary="Recetas" />
            </ListItemButton>
          </ListItem>
          <ListItem disablePadding>
            <ListItemButton onClick={() => { onClose && onClose(); navigate('/ajustes'); }}>
              <ListItemIcon><SettingsIcon /></ListItemIcon>
              <ListItemText primary="Ajustes" />
            </ListItemButton>
          </ListItem>
          <ListItem disablePadding>
            <ListItemButton onClick={() => { onLogout && onLogout(); }}>
              <ListItemIcon><LogoutIcon /></ListItemIcon>
              <ListItemText primary="Cerrar sesión" />
            </ListItemButton>
          </ListItem>
        </List>
      </Box>
    </Drawer>
  );
}
