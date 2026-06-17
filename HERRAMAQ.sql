-- BASE DE DATOS: Ferretería HERREMAQ
CREATE DATABASE Herramaq;
USE Herramaq;

-- TABLA: CATEGORIA
CREATE TABLE Categoria (
    ID_Categoria  INT PRIMARY KEY IDENTITY(1,1),
    Nombre        VARCHAR(50) NOT NULL,
    Descripcion   VARCHAR(100)
);

-- TABLA: PROVEEDOR
CREATE TABLE Proveedor (
    ID_Proveedor  INT PRIMARY KEY IDENTITY(1,1),
    RUC           CHAR(11)    UNIQUE NOT NULL,
    RazonSocial   VARCHAR(100) NOT NULL,
    Direccion     VARCHAR(100),
    Telefono      VARCHAR(9)
);

-- TABLA: CLIENTE
CREATE TABLE Cliente (
    ID_Cliente    INT PRIMARY KEY IDENTITY(1,1),
    DNI_RUC       VARCHAR(11)  UNIQUE NOT NULL,
    NombreRazon   VARCHAR(100) NOT NULL,
    Direccion     VARCHAR(100),
    Telefono      VARCHAR(9)
);

-- TABLA: USUARIO
CREATE TABLE Usuario (
    ID_Usuario    INT PRIMARY KEY IDENTITY(1,1),
    NombreUsuario VARCHAR(30)  UNIQUE NOT NULL,
    Contrasena    VARCHAR(30)  NOT NULL,
    Rol           VARCHAR(20)  NOT NULL CHECK (Rol IN ('Administrador', 'Vendedor')),
    NombreCompleto VARCHAR(60) NOT NULL
);

-- TABLA: PRODUCTO
CREATE TABLE Producto (
    ID_Producto   INT PRIMARY KEY IDENTITY(1,1),
    CodigoBarra   VARCHAR(20)  UNIQUE NOT NULL,
    Descripcion   VARCHAR(100) NOT NULL,
    PrecioCompra  DECIMAL(10,2) NOT NULL CHECK (PrecioCompra > 0),
    PrecioVenta   DECIMAL(10,2) NOT NULL CHECK (PrecioVenta > 0),
    Stock         INT           NOT NULL CHECK (Stock >= 0),
    ID_Categoria  INT           NOT NULL,
    ID_Proveedor  INT           NOT NULL,
    FOREIGN KEY (ID_Categoria) REFERENCES Categoria(ID_Categoria),
    FOREIGN KEY (ID_Proveedor) REFERENCES Proveedor(ID_Proveedor)
);

-- TABLA: VENTA
CREATE TABLE Venta (
    ID_Venta        INT PRIMARY KEY IDENTITY(1,1),
    FechaVenta      DATE         NOT NULL,
    TipoComprobante VARCHAR(20)  NOT NULL CHECK (TipoComprobante IN ('Boleta', 'Factura', 'Ticket')),
    NroComprobante  VARCHAR(15)  NOT NULL,
    Total           DECIMAL(10,2) NOT NULL CHECK (Total >= 0),
    ID_Cliente      INT           NOT NULL,
    ID_Usuario      INT           NOT NULL,
    FOREIGN KEY (ID_Cliente)  REFERENCES Cliente(ID_Cliente),
    FOREIGN KEY (ID_Usuario)  REFERENCES Usuario(ID_Usuario)
);

-- TABLA: DETALLE_VENTA
CREATE TABLE Detalle_Venta (
    ID_Detalle    INT PRIMARY KEY IDENTITY(1,1),
    Cantidad      INT            NOT NULL CHECK (Cantidad > 0),
    PrecioUnitario DECIMAL(10,2) NOT NULL CHECK (PrecioUnitario > 0),
    Subtotal      AS (Cantidad * PrecioUnitario),   -- Calculado automáticamente
    ID_Venta      INT            NOT NULL,
    ID_Producto   INT            NOT NULL,
    FOREIGN KEY (ID_Venta)    REFERENCES Venta(ID_Venta),
    FOREIGN KEY (ID_Producto) REFERENCES Producto(ID_Producto)
);

-- DATOS DE PRUEBA
INSERT INTO Categoria (Nombre, Descripcion) VALUES
('Herramientas',  'Herramientas manuales y eléctricas'),
('Electricidad',  'Cables, interruptores y accesorios eléctricos'),
('Plomería',      'Tuberías, llaves y accesorios de agua');

INSERT INTO Proveedor (RUC, RazonSocial, Direccion, Telefono) VALUES
('20112233441', 'Distribuidora Ferretera SAC',  'Av. Industrial 123, Lima',    '074123456'),
('20998877661', 'Suministros del Norte EIRL',   'Jr. Comercio 456, Cajamarca', '076654321');

INSERT INTO Cliente (DNI_RUC, NombreRazon, Direccion, Telefono) VALUES
('44556677',     'Juan Carlos Pérez Quispe',    'Jr. Los Andes 200, Cajamarca', '976543210'),
('20445566778',  'Constructora Norteña SAC',    'Av. Héroes 890, Cajamarca',    '074987654');

INSERT INTO Usuario (NombreUsuario, Contrasena, Rol, NombreCompleto) VALUES
('admin',    'admin123',   'Administrador', 'Carlos Mendoza Ruiz'),
('vendedor1','venta2026',  'Vendedor',      'Ana Torres Solis');

INSERT INTO Producto (CodigoBarra, Descripcion, PrecioCompra, PrecioVenta, Stock, ID_Categoria, ID_Proveedor) VALUES
('7501000111111', 'Martillo de Carpintero 16oz',   25.00,  45.00, 30, 1, 1),
('7501000222222', 'Cable THW 2.5mm x metro',        3.50,   6.00, 200, 2, 1),
('7501000333333', 'Llave de Paso 1/2 PVC',          8.00,  15.00,  50, 3, 2);

INSERT INTO Venta (FechaVenta, TipoComprobante, NroComprobante, Total, ID_Cliente, ID_Usuario) VALUES
('2026-06-10', 'Boleta',  'B001-00001', 105.00, 1, 2),
('2026-06-11', 'Factura', 'F001-00001', 450.00, 2, 2);

INSERT INTO Detalle_Venta (Cantidad, PrecioUnitario, ID_Venta, ID_Producto) VALUES
(2, 45.00, 1, 1),   -- 2 martillos en venta 1
(5,  6.00, 1, 2),   -- 5 metros de cable en venta 1
(30, 15.00, 2, 3);  -- 30 llaves de paso en venta 2

-- CONSULTAS DE VERIFICACIÓN
SELECT ID_Categoria, Nombre, Descripcion FROM Categoria;
SELECT ID_Proveedor, RUC, RazonSocial, Direccion, Telefono FROM Proveedor;
SELECT ID_Cliente, DNI_RUC, NombreRazon, Direccion, Telefono FROM Cliente;
SELECT ID_Usuario, NombreUsuario, Rol, NombreCompleto FROM Usuario;
SELECT ID_Producto, CodigoBarra, Descripcion, PrecioCompra, PrecioVenta, Stock, ID_Categoria, ID_Proveedor FROM Producto;
SELECT ID_Venta, FechaVenta, TipoComprobante, NroComprobante, Total, ID_Cliente, ID_Usuario FROM Venta;
SELECT ID_Detalle, Cantidad, PrecioUnitario, Subtotal, ID_Venta, ID_Producto FROM Detalle_Venta;

-- CONSULTAS CON INNER JOIN
-- Productos con su categoría y proveedor
SELECT p.ID_Producto, p.CodigoBarra, p.Descripcion, c.Nombre AS Categoria,
p.PrecioVenta, p.Stock, s.RazonSocial AS Proveedor
FROM Producto p
INNER JOIN Categoria c ON c.ID_Categoria = p.ID_Categoria
INNER JOIN Proveedor s ON s.ID_Proveedor = p.ID_Proveedor;

-- Ventas con cliente y usuario responsable
SELECT v.ID_Venta, v.FechaVenta, v.TipoComprobante, v.NroComprobante,
cl.NombreRazon AS Cliente, u.NombreCompleto AS Vendedor, v.Total
FROM Venta v
INNER JOIN Cliente  cl ON cl.ID_Cliente = v.ID_Cliente
INNER JOIN Usuario   u ON  u.ID_Usuario = v.ID_Usuario;

-- Detalle de venta con nombre de producto y subtotal
SELECT dv.ID_Venta, p.Descripcion AS Producto,
dv.Cantidad, dv.PrecioUnitario, dv.Subtotal
FROM Detalle_Venta dv
INNER JOIN Producto p ON p.ID_Producto = dv.ID_Producto;

-- CONSULTAS DE CONJUNTOS (UNION / INTERSECT / EXCEPT)
--UNION: Lista combinada de clientes y proveedores
(SELECT 'Cliente'   AS Tipo, DNI_RUC AS Identificador, NombreRazon AS Nombre FROM Cliente)
UNION
(SELECT 'Proveedor' AS Tipo, RUC     AS Identificador, RazonSocial AS Nombre FROM Proveedor);

--INTERSECT: Direcciones que coinciden entre clientes y proveedores
(SELECT Direccion FROM Cliente)
INTERSECT
(SELECT Direccion FROM Proveedor);

--EXCEPT A-B: Direcciones de clientes que no estan en proveedores
(SELECT Direccion FROM Cliente)
EXCEPT
(SELECT Direccion FROM Proveedor);

--EXCEPT B-A: Direcciones de proveedores que no estan en clientes
(SELECT Direccion FROM Proveedor)
EXCEPT
(SELECT Direccion FROM Cliente);