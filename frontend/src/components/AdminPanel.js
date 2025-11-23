import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Container,
  Typography,
  Tabs,
  Tab,
  Paper,
  Alert,
  CircularProgress
} from '@mui/material';
import {
  People as PeopleIcon,
  Restaurant as RestaurantIcon,
  Public as PublicIcon,
  Category as CategoryIcon
} from '@mui/icons-material';
import { isAdmin } from '../api';
import AdminUsuarios from './AdminUsuarios';
import AdminRecetas from './AdminRecetas';
import AdminPaises from './AdminPaises';
import AdminCategorias from './AdminCategorias';

function TabPanel({ children, value, index }) {
  return (
    <div hidden={value !== index} style={{ paddingTop: '24px' }}>
      {value === index && <Box>{children}</Box>}
    </div>
  );
}

function AdminPanel() {
  const navigate = useNavigate();
  const [tabValue, setTabValue] = useState(0);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Verificar si el usuario es admin
    const checkAdmin = () => {
      if (!isAdmin()) {
        navigate('/');
        return;
      }
      setLoading(false);
    };
    
    checkAdmin();
  }, [navigate]);

  const handleTabChange = (event, newValue) => {
    setTabValue(newValue);
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '80vh' }}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Container maxWidth="xl" sx={{ py: 4 }}>
      <Paper elevation={3} sx={{ p: 3, mb: 3 }}>
        <Typography variant="h4" component="h1" gutterBottom sx={{ fontWeight: 'bold', color: 'primary.main' }}>
          🛡️ Panel de Administración
        </Typography>
      </Paper>

      <Paper elevation={3}>
        <Tabs
          value={tabValue}
          onChange={handleTabChange}
          variant="scrollable"
          scrollButtons="auto"
          sx={{ borderBottom: 1, borderColor: 'divider' }}
        >
          <Tab icon={<PeopleIcon />} label="Usuarios" />
          <Tab icon={<RestaurantIcon />} label="Recetas" />
          <Tab icon={<PublicIcon />} label="Países" />
          <Tab icon={<CategoryIcon />} label="Categorías" />
        </Tabs>

        <Box sx={{ p: 3 }}>
          <TabPanel value={tabValue} index={0}>
            <AdminUsuarios />
          </TabPanel>
          <TabPanel value={tabValue} index={1}>
            <AdminRecetas />
          </TabPanel>
          <TabPanel value={tabValue} index={2}>
            <AdminPaises />
          </TabPanel>
          <TabPanel value={tabValue} index={3}>
            <AdminCategorias />
          </TabPanel>
        </Box>
      </Paper>
    </Container>
  );
}

export default AdminPanel;
