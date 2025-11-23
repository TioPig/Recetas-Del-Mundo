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
import Divider from '@mui/material/Divider';
import Avatar from '@mui/material/Avatar';
import BookmarkIcon from '@mui/icons-material/Bookmark';
import MenuBookIcon from '@mui/icons-material/MenuBook';
import SettingsIcon from '@mui/icons-material/Settings';
import LogoutIcon from '@mui/icons-material/Logout';
import AdminPanelSettingsIcon from '@mui/icons-material/AdminPanelSettings';
import CloseIcon from '@mui/icons-material/Close';
import { isAdmin } from '../api';

export default function UserSidebar({ open, onClose, onLogout }){
  // read user from localStorage
  let user = null;
  try{ user = JSON.parse(localStorage.getItem('user') || 'null'); }catch(e){ user = null; }
  const navigate = useNavigate();
  const isUserAdmin = isAdmin();

  const displayName = user && (user.nombre || user.name || user.firstName) ? `${user.nombre || user.name || ''} ${user.apellido || user.lastName || ''}`.trim() : (user && user.username ? user.username : 'Usuario');
  const email = user && (user.email || user.usuario || user.mail) ? (user.email || user.usuario || user.mail) : '';

  return (
    <Drawer 
      anchor="right" 
      open={open} 
      onClose={onClose}
      PaperProps={{
        sx: {
          width: { xs: '85vw', sm: 360 },
          background: 'linear-gradient(180deg, #667EEA 0%, #764BA2 100%)',
        }
      }}
    >
      <Box sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
        {/* Header with Close Button */}
        <Box sx={{ 
          p: 2, 
          display: 'flex', 
          justifyContent: 'space-between', 
          alignItems: 'center',
          borderBottom: '1px solid rgba(255,255,255,0.2)'
        }}>
          <Typography 
            variant="h6" 
            sx={{ 
              color: 'white', 
              fontFamily: 'Lato, sans-serif',
              fontWeight: 900
            }}
          >
            Mi Perfil
          </Typography>
          <IconButton 
            onClick={onClose}
            sx={{ 
              color: 'white',
              '&:hover': { 
                backgroundColor: 'rgba(255,255,255,0.1)' 
              }
            }}
          >
            <CloseIcon />
          </IconButton>
        </Box>

        {/* User Info */}
        <Box sx={{ 
          p: 3, 
          textAlign: 'center',
          borderBottom: '1px solid rgba(255,255,255,0.2)'
        }}>
          <Avatar
            src="/img/user-cheems.png"
            alt="avatar"
            sx={{
              width: 100,
              height: 100,
              margin: '0 auto',
              mb: 2,
              border: '4px solid white',
              boxShadow: '0 4px 16px rgba(0,0,0,0.2)'
            }}
          />
          <Typography 
            variant="h6" 
            sx={{ 
              color: 'white',
              fontFamily: 'Lato, sans-serif',
              fontWeight: 900,
              mb: 0.5
            }}
          >
            {displayName}
          </Typography>
          <Typography 
            variant="body2" 
            sx={{ 
              color: 'rgba(255,255,255,0.9)',
              fontFamily: 'Open Sans, sans-serif'
            }}
          >
            {email}
          </Typography>
        </Box>

        {/* Menu Items */}
        <Box sx={{ 
          flex: 1, 
          overflow: 'auto',
          backgroundColor: 'white',
          p: 1
        }}>
          <List>
            {isUserAdmin && (
              <>
                <ListItem disablePadding>
                  <ListItemButton 
                    onClick={() => { onClose && onClose(); navigate('/admin'); }}
                    sx={{ 
                      borderRadius: 2,
                      mb: 1,
                      background: 'linear-gradient(135deg, #667EEA, #764BA2)',
                      color: 'white',
                      '&:hover': { 
                        background: 'linear-gradient(135deg, #764BA2, #667EEA)',
                        transform: 'translateX(5px)',
                        transition: 'all 0.3s'
                      }
                    }}
                  >
                    <ListItemIcon>
                      <AdminPanelSettingsIcon sx={{ color: 'white' }} />
                    </ListItemIcon>
                    <ListItemText 
                      primary="Panel Admin" 
                      primaryTypographyProps={{ 
                        fontWeight: 700,
                        fontFamily: 'Roboto, sans-serif'
                      }}
                    />
                  </ListItemButton>
                </ListItem>
                <Divider sx={{ my: 1 }} />
              </>
            )}
            
            <ListItem disablePadding>
              <ListItemButton 
                onClick={() => { onClose && onClose(); navigate('/mi/favoritos'); }}
                sx={{
                  borderRadius: 2,
                  mb: 0.5,
                  transition: 'all 0.2s',
                  '&:hover': {
                    backgroundColor: 'rgba(245, 101, 101, 0.1)',
                    transform: 'translateX(5px)',
                    '& .MuiListItemIcon-root': { color: '#F56565' },
                    '& .MuiListItemText-primary': { color: '#F56565' }
                  }
                }}
              >
                <ListItemIcon>
                  <BookmarkIcon sx={{ color: '#F56565' }} />
                </ListItemIcon>
                <ListItemText 
                  primary="Mis Favoritos" 
                  primaryTypographyProps={{
                    fontFamily: 'Open Sans, sans-serif',
                    fontWeight: 600
                  }}
                />
              </ListItemButton>
            </ListItem>

            <ListItem disablePadding>
              <ListItemButton 
                onClick={() => { onClose && onClose(); navigate('/mi/recetas'); }}
                sx={{
                  borderRadius: 2,
                  mb: 0.5,
                  transition: 'all 0.2s',
                  '&:hover': {
                    backgroundColor: 'rgba(240, 147, 251, 0.1)',
                    transform: 'translateX(5px)',
                    '& .MuiListItemIcon-root': { color: '#F093FB' },
                    '& .MuiListItemText-primary': { color: '#F093FB' }
                  }
                }}
              >
                <ListItemIcon>
                  <MenuBookIcon sx={{ color: '#F093FB' }} />
                </ListItemIcon>
                <ListItemText 
                  primary="Mis Recetas" 
                  primaryTypographyProps={{
                    fontFamily: 'Open Sans, sans-serif',
                    fontWeight: 600
                  }}
                />
              </ListItemButton>
            </ListItem>

            <ListItem disablePadding>
              <ListItemButton 
                onClick={() => { onClose && onClose(); navigate('/ajustes'); }}
                sx={{
                  borderRadius: 2,
                  mb: 0.5,
                  transition: 'all 0.2s',
                  '&:hover': {
                    backgroundColor: 'rgba(102, 126, 234, 0.1)',
                    transform: 'translateX(5px)',
                    '& .MuiListItemIcon-root': { color: '#667EEA' },
                    '& .MuiListItemText-primary': { color: '#667EEA' }
                  }
                }}
              >
                <ListItemIcon>
                  <SettingsIcon sx={{ color: '#667EEA' }} />
                </ListItemIcon>
                <ListItemText 
                  primary="Configuración" 
                  primaryTypographyProps={{
                    fontFamily: 'Open Sans, sans-serif',
                    fontWeight: 600
                  }}
                />
              </ListItemButton>
            </ListItem>

            <Divider sx={{ my: 2 }} />

            <ListItem disablePadding>
              <ListItemButton 
                onClick={() => { onLogout && onLogout(); }}
                sx={{
                  borderRadius: 2,
                  transition: 'all 0.2s',
                  '&:hover': {
                    backgroundColor: 'rgba(26, 32, 44, 0.1)',
                    transform: 'translateX(5px)',
                    '& .MuiListItemIcon-root': { color: '#1A202C' },
                    '& .MuiListItemText-primary': { color: '#1A202C' }
                  }
                }}
              >
                <ListItemIcon>
                  <LogoutIcon sx={{ color: '#718096' }} />
                </ListItemIcon>
                <ListItemText 
                  primary="Cerrar Sesión" 
                  primaryTypographyProps={{
                    fontFamily: 'Open Sans, sans-serif',
                    fontWeight: 600,
                    color: '#718096'
                  }}
                />
              </ListItemButton>
            </ListItem>
          </List>
        </Box>
      </Box>
    </Drawer>
  );
}
