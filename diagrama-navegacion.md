# Diagrama de Flujo - Navegación Recetas Del Mundo

## Flujo de Navegación del Usuario (Basado en Componentes React)

```mermaid
flowchart TD
    Start([Usuario accede al sitio]) --> Home[Home.js<br/>Página Principal]
    
    Home --> HeaderNav{Header.js<br/>Navegación}
    
    HeaderNav --> BtnInicio[Botón Inicio]
    HeaderNav --> BtnPaises[Botón Países]
    HeaderNav --> BtnCategorias[Botón Categorías]
    HeaderNav --> BtnBuscar[Barra de Búsqueda]
    HeaderNav --> BtnLogin[Botón Login]
    HeaderNav --> BtnRegister[Botón Registrarse]
    HeaderNav --> BtnDonate[Botón Donar]
    
    BtnInicio --> Home
    
    BtnLogin --> Login[Login.js<br/>Iniciar Sesión]
    Login --> AuthCheck{¿Credenciales<br/>válidas?}
    AuthCheck -->|No| ErrorMsg[Mostrar Error]
    ErrorMsg --> Login
    AuthCheck -->|Sí| AuthSuccess[Guardar Token JWT<br/>localStorage]
    
    BtnRegister --> Register[Register.js<br/>Registro de Usuario]
    Register --> RegValidation{¿Datos válidos?}
    RegValidation -->|No| RegError[Mostrar Error]
    RegError --> Register
    RegValidation -->|Sí| AuthSuccess
    
    AuthSuccess --> HomeAuth[Home.js<br/>Usuario Autenticado]
    
    HomeAuth --> HeaderAuth[Header.js<br/>con Usuario]
    HeaderAuth --> UserMenu[UserSidebar.js<br/>Menú de Usuario]
    
    UserMenu --> BtnMisRecetas[Mis Recetas]
    UserMenu --> BtnFavoritos[Mis Favoritos]
    UserMenu --> BtnAjustes[Ajustes]
    UserMenu --> BtnCrear[Crear Receta]
    UserMenu --> BtnAdmin[Admin Panel]
    UserMenu --> BtnLogout[Cerrar Sesión]
    
    BtnMisRecetas --> UserRecetas[UserRecetas.js<br/>Mis Recetas]
    BtnFavoritos --> UserFavoritos[UserFavoritos.js<br/>Recetas Favoritas]
    BtnAjustes --> Ajustes[Ajustes.js<br/>Editar Perfil]
    BtnCrear --> NuevaReceta[NuevaReceta.js<br/>Formulario de Receta]
    BtnLogout --> Logout[Borrar Token<br/>localStorage]
    Logout --> Home
    
    BtnPaises --> Paises[Paises.js<br/>Lista de Países]
    Paises --> SelectPais[Seleccionar País]
    SelectPais --> RecetasByPais[RecetasByPais.js<br/>Recetas del País]
    
    BtnCategorias --> Categorias[Categorias.js<br/>Lista de Categorías]
    Categorias --> SelectCat[Seleccionar Categoría]
    SelectCat --> RecetasByCategoria[RecetasByCategoria.js<br/>Recetas de Categoría]
    
    BtnBuscar --> SearchResults[SearchResults.js<br/>Resultados Búsqueda]
    
    Home --> RecetaCard[Card de Receta<br/>en Home]
    RecetasByPais --> RecetaCard
    RecetasByCategoria --> RecetaCard
    SearchResults --> RecetaCard
    UserRecetas --> RecetaCard
    UserFavoritos --> RecetaCard
    
    RecetaCard --> RecetaDetail[Detalle de Receta<br/>en Home.js]
    
    RecetaDetail --> CheckAuth{¿Autenticado?}
    CheckAuth -->|No| AuthPrompt[AuthPromptDialog.js<br/>Solicita Login]
    AuthPrompt --> Login
    CheckAuth -->|Sí| InteractReceta[Interacciones]
    
    InteractReceta --> BtnLike[Me Gusta<br/>ThumbUp Icon]
    InteractReceta --> BtnFav[Favorito<br/>Bookmark Icon]
    InteractReceta --> BtnStar[Calificar<br/>Star Icon]
    InteractReceta --> BtnComment[Comentar]
    
    BtnStar --> RatingDialog[RatingDialog.js<br/>Calificar 1-5 estrellas]
    RatingDialog --> SaveRating[Guardar Calificación<br/>API]
    SaveRating --> RecetaDetail
    
    BtnComment --> CommentForm[Formulario<br/>Comentario]
    CommentForm --> SaveComment[Guardar Comentario<br/>API]
    SaveComment --> RecetaDetail
    
    NuevaReceta --> RecetaForm[Formulario Completo]
    RecetaForm --> AddIngredientes[Agregar<br/>Ingredientes]
    AddIngredientes --> SaveNuevaReceta{¿Guardar?}
    SaveNuevaReceta -->|Sí| CreateAPI[POST /recetas<br/>API]
    SaveNuevaReceta -->|No| RecetaForm
    CreateAPI --> HomeAuth
    
    BtnAdmin --> AdminCheck{¿Es Admin/SUP?}
    AdminCheck -->|No| AccessDenied[Acceso Denegado]
    AccessDenied --> HomeAuth
    AdminCheck -->|Sí| AdminPanel[AdminPanel.js<br/>Panel Admin]
    
    AdminPanel --> AdminTabs{Tabs de Admin}
    AdminTabs --> Tab1[Tab 0:<br/>AdminUsuarios.js]
    AdminTabs --> Tab2[Tab 1:<br/>AdminRecetas.js]
    AdminTabs --> Tab3[Tab 2:<br/>AdminPaises.js]
    AdminTabs --> Tab4[Tab 3:<br/>AdminCategorias.js]
    
    Tab1 --> CRUDUsuarios[CRUD Usuarios<br/>GET, POST, PUT, DELETE]
    Tab2 --> CRUDRecetas[CRUD Recetas<br/>GET, POST, PUT, DELETE]
    Tab3 --> CRUDPaises[CRUD Países<br/>GET, POST, PUT, DELETE]
    Tab4 --> CRUDCategorias[CRUD Categorías<br/>GET, POST, PUT, DELETE]
    
    CRUDUsuarios --> AdminPanel
    CRUDRecetas --> AdminPanel
    CRUDPaises --> AdminPanel
    CRUDCategorias --> AdminPanel
    
    BtnDonate --> DonateCheck{¿Autenticado?}
    DonateCheck -->|No| DonatePrompt[Alert: Iniciar Sesión]
    DonatePrompt --> Login
    DonateCheck -->|Sí| DonateAPI[Crear Sesión<br/>Stripe/Donación]
    DonateAPI --> StripeRedirect[Redirigir a Stripe<br/>o Confirmar]
    StripeRedirect --> HomeAuth
    
    style Start fill:#F75442,stroke:#99682E,stroke-width:3px,color:#fff
    style Home fill:#F9E9AE,stroke:#F75442,stroke-width:2px,color:#000
    style HomeAuth fill:#F9E9AE,stroke:#F75442,stroke-width:2px,color:#000
    style Login fill:#99682E,stroke:#F75442,stroke-width:2px,color:#fff
    style Register fill:#99682E,stroke:#F75442,stroke-width:2px,color:#fff
    style AuthSuccess fill:#27ae60,stroke:#F75442,stroke-width:2px,color:#fff
    style RecetaDetail fill:#F75442,stroke:#99682E,stroke-width:3px,color:#fff
    style AdminPanel fill:#F75442,stroke:#99682E,stroke-width:3px,color:#fff
    style UserMenu fill:#F9E9AE,stroke:#F75442,stroke-width:2px,color:#000
    style NuevaReceta fill:#F75442,stroke:#99682E,stroke-width:2px,color:#fff
    style RatingDialog fill:#F9E9AE,stroke:#F75442,stroke-width:2px,color:#000
    style AuthPrompt fill:#99682E,stroke:#F75442,stroke-width:2px,color:#fff
```

## Componentes React Identificados

### **Páginas Principales:**
- `Home.js` - Página de inicio con recetas trending y receta del día
- `Login.js` - Autenticación de usuarios
- `Register.js` - Registro de nuevos usuarios
- `Paises.js` - Lista de países disponibles
- `Categorias.js` - Lista de categorías de recetas

### **Navegación y Layout:**
- `Header.js` - Barra de navegación superior
- `Footer.js` - Pie de página
- `UserSidebar.js` - Menú lateral del usuario autenticado

### **Gestión de Recetas:**
- `NuevaReceta.js` - Crear nueva receta
- `UserRecetas.js` - Recetas creadas por el usuario
- `RecetasByPais.js` - Recetas filtradas por país
- `RecetasByCategoria.js` - Recetas filtradas por categoría
- `SearchResults.js` - Resultados de búsqueda

### **Funcionalidades Sociales:**
- `UserFavoritos.js` - Recetas marcadas como favoritas
- `RatingDialog.js` - Diálogo para calificar recetas
- `AuthPromptDialog.js` - Solicitud de autenticación
- `DebugLikes.js` - Debug de me gustas

### **Panel Administrativo:**
- `AdminPanel.js` - Dashboard principal de administración (Tabs)
- `AdminUsuarios.js` - Gestión de usuarios (Tab 0)
- `AdminRecetas.js` - Gestión de recetas (Tab 1)
- `AdminPaises.js` - Gestión de países (Tab 2)
- `AdminCategorias.js` - Gestión de categorías (Tab 3)

### **Configuración de Usuario:**
- `Ajustes.js` - Editar perfil y cambiar contraseña

## Leyenda de Colores

- **Naranja (#F75442)**: Páginas clave y acciones importantes
- **Crema (#F9E9AE)**: Componentes de navegación y contenido
- **Café (#99682E)**: Autenticación y autorización
- **Verde (#27ae60)**: Éxito en operaciones
