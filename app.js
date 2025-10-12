// routes - rutas
const LanguageRoutes = require('./routes/language.routes');
const express = require('express')
const morgan = require ('morgan')
const app=express(); //ejecu express
const cors = require('cors')

// settings
app.set("port", process.env.PORT || 3000);

// middleware
app.use(morgan("dev"));
app.use(cors());
app.use(express.json());

// routes
app.use("/auth", LanguageRoutes);

// Ruta de prueba
app.get('/', (req, res) => {
    res.json({
        message: 'API de Recetas - Login Test',
        endpoints: {
            login: 'POST /auth/login',
            usuarios: 'GET /auth/usuarios'
        }
    });
});

module.exports = app;