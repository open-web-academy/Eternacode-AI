// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TextStorage {
    struct Version {
        string text;
        uint256 modifiedAt;
    }
    
    struct TextEntry {
        string currentText;
        uint256 createdAt;
        uint256 updatedAt;
        Version[] versions;
        mapping(address => bool) allowedViewers;
    }

    struct AccessibleEntry {
        address owner;
        string name;
        string currentText;
        uint256 createdAt;
        uint256 updatedAt;
    }
    
    // Mapeos principales
    mapping(address => mapping(string => TextEntry)) private _entries;
    mapping(address => string[]) private _userEntries; // Entradas propias
    mapping(address => AccessibleEntry[]) private _allowedEntries; // Entradas compartidas con el usuario

    // Eventos
    event EntryCreated(address indexed user, string name, uint256 timestamp);
    event EntryUpdated(address indexed user, string name, uint256 timestamp);
    event PermissionGranted(address indexed user, string name, address viewer);
    event PermissionRevoked(address indexed user, string name, address viewer);
    
    // Función MODIFICADA para llevar registro de entradas propias
    function createEntry(string memory name, string memory text) external {
        require(bytes(name).length > 0, "Nombre vacio");
        require(_entries[msg.sender][name].createdAt == 0, "Entrada existente");
        
        TextEntry storage newEntry = _entries[msg.sender][name];
        newEntry.currentText = text;
        newEntry.createdAt = block.timestamp;
        newEntry.updatedAt = block.timestamp;
        newEntry.versions.push(Version(text, block.timestamp));
        
        _userEntries[msg.sender].push(name); // Registrar entrada propia
        emit EntryCreated(msg.sender, name, block.timestamp);
    }

    function updateEntry(string memory name, string memory newText) external {
        TextEntry storage entry = _entries[msg.sender][name];
        require(entry.createdAt != 0, "Entrada no existe");
        
        entry.currentText = newText;
        entry.updatedAt = block.timestamp;
        entry.versions.push(Version(newText, block.timestamp));
        
        emit EntryUpdated(msg.sender, name, block.timestamp);
    }

    // Funciones MODIFICADAS para manejar permisos y registros compartidos
    function grantPermission(string memory name, address viewer) external {
        require(_entries[msg.sender][name].createdAt != 0, "Entrada no existe");
        _entries[msg.sender][name].allowedViewers[viewer] = true;
        
        // Añadir a la lista de entradas accesibles del viewer
        TextEntry storage entry = _entries[msg.sender][name];
        _allowedEntries[viewer].push(AccessibleEntry(
            msg.sender,
            name,
            entry.currentText,
            entry.createdAt,
            entry.updatedAt
        ));
        
        emit PermissionGranted(msg.sender, name, viewer);
    }

    function revokePermission(string memory name, address viewer) external {
        delete _entries[msg.sender][name].allowedViewers[viewer];
        
        // Remover de la lista de entradas accesibles del viewer
        AccessibleEntry[] storage entries = _allowedEntries[viewer];
        for(uint256 i = 0; i < entries.length; i++) {
            if(entries[i].owner == msg.sender && 
               keccak256(bytes(entries[i].name)) == keccak256(bytes(name))) {
                entries[i] = entries[entries.length - 1];
                entries.pop();
                break;
            }
        }
        
        emit PermissionRevoked(msg.sender, name, viewer);
    }

    // NUEVA FUNCIÓN: Obtener todas las entradas accesibles
    function getAccessibleEntries() external view returns (AccessibleEntry[] memory, AccessibleEntry[] memory) {
        // Entradas propias
        string[] storage ownEntries = _userEntries[msg.sender];
        AccessibleEntry[] memory ownResult = new AccessibleEntry[](ownEntries.length);
        
        for(uint256 i = 0; i < ownEntries.length; i++) {
            TextEntry storage entry = _entries[msg.sender][ownEntries[i]];
            ownResult[i] = AccessibleEntry(
                msg.sender,
                ownEntries[i],
                entry.currentText,
                entry.createdAt,
                entry.updatedAt
            );
        }
        
        // Entradas compartidas con el usuario
        AccessibleEntry[] storage sharedEntries = _allowedEntries[msg.sender];
        
        return (ownResult, sharedEntries);
    }

    function getCurrentText(address user, string memory name) external view returns (
        string memory text,
        uint256 createdAt,
        uint256 updatedAt
    ) {
        TextEntry storage entry = _entries[user][name];
        _checkPermissions(user, name);
        return (entry.currentText, entry.createdAt, entry.updatedAt);
    }

    function getVersionCount(address user, string memory name) external view returns (uint256) {
        _checkPermissions(user, name);
        return _entries[user][name].versions.length;
    }

    function getSpecificVersion(address user, string memory name, uint256 index) external view returns (
        string memory text,
        uint256 modifiedAt
    ) {
        _checkPermissions(user, name);
        Version storage version = _entries[user][name].versions[index];
        return (version.text, version.modifiedAt);
    }

    function getRecentVersions(address user, string memory name, uint256 count) external view returns (Version[] memory) {
        _checkPermissions(user, name);
        Version[] storage allVersions = _entries[user][name].versions;
        uint256 start = allVersions.length > count ? allVersions.length - count : 0;
        
        Version[] memory result = new Version[](allVersions.length - start);
        for(uint256 i = start; i < allVersions.length; i++) {
            result[i - start] = allVersions[i];
        }
        return result;
    }

    // Verificación de permisos interna
    function _checkPermissions(address user, string memory name) private view {
        require(_entries[user][name].createdAt != 0, "Entrada no existe");
        require(
            user == msg.sender || 
            _entries[user][name].allowedViewers[msg.sender],
            "Sin permisos"
        );
    }
}