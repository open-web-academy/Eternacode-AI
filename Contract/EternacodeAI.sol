// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EternacodeAI {
    address public owner;
    
    struct AIModelVersion {
        string content;
        uint256 timestamp;
        address author; // Nuevo campo para rastrear al autor
    }

    // Mapeos principales
    mapping(uint256 => AIModelVersion[]) private idToVersions;
    mapping(uint256 => mapping(address => bool)) private permissions;
    
    // Nuevas estructuras para el tracking de últimas versiones
    mapping(uint256 => address) public idToLatestAuthor;
    uint256[] private allIds; // Lista de todos los IDs existentes

    event VersionAdded(uint256 indexed id, address indexed author, uint256 timestamp);
    event PermissionGranted(uint256 indexed id, address indexed wallet);
    event PermissionRevoked(uint256 indexed id, address indexed wallet);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    modifier hasPermission(uint256 id) {
        require(
            msg.sender == owner || permissions[id][msg.sender],
            "No permissions for this ID"
        );
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // ================== FUNCIONES PRINCIPALES ==================
    function addVersion(uint256 id, string memory text) public hasPermission(id) {
        if (idToVersions[id].length == 0) {
            allIds.push(id); // Registrar nuevo ID
        }
        
        idToVersions[id].push(AIModelVersion({
            content: text,
            timestamp: block.timestamp,
            author: msg.sender
        }));
        
        idToLatestAuthor[id] = msg.sender; // Actualizar último autor
        emit VersionAdded(id, msg.sender, block.timestamp);
    }

    // ================== FUNCIONES DE CONSULTA ==================
    // Obtener las últimas N versiones de un ID (pagina hacia atrás)
    function getVersionsPaginated(uint256 id, uint256 count) public view hasPermission(id) returns (AIModelVersion[] memory) {
        uint256 total = idToVersions[id].length;
        uint256 size = (count > total) ? total : count;
        
        AIModelVersion[] memory result = new AIModelVersion[](size);
        for (uint256 i = 0; i < size; i++) {
            result[i] = idToVersions[id][total - 1 - i];
        }
        return result;
    }

    // Obtener una versión específica por índice
    function getVersion(uint256 id, uint256 index) public view hasPermission(id) returns (AIModelVersion memory) {
        require(index < idToVersions[id].length, "Invalid version index");
        return idToVersions[id][index];
    }

    // Obtener la última versión de un ID
    function getLatestVersion(uint256 id) public view hasPermission(id) returns (AIModelVersion memory) {
        require(idToVersions[id].length > 0, "No versions exist");
        return idToVersions[id][idToVersions[id].length - 1];
    }

    // Obtener todos los IDs donde el usuario es autor de la última versión
    function getUserLatestIds(address user) public view returns (uint256[] memory) {
        uint256[] memory temp = new uint256[](allIds.length);
        uint256 counter = 0;
        
        for (uint256 i = 0; i < allIds.length; i++) {
            uint256 id = allIds[i];
            if (idToLatestAuthor[id] == user) {
                temp[counter] = id;
                counter++;
            }
        }
        
        uint256[] memory result = new uint256[](counter);
        for (uint256 i = 0; i < counter; i++) {
            result[i] = temp[i];
        }
        return result;
    }

    // ================== FUNCIONES DE PERMISOS ==================
    function grantPermission(uint256 id, address wallet) public onlyOwner {
        permissions[id][wallet] = true;
        emit PermissionGranted(id, wallet);
    }

    function revokePermission(uint256 id, address wallet) public onlyOwner {
        permissions[id][wallet] = false;
        emit PermissionRevoked(id, wallet);
    }

    function checkPermission(uint256 id, address wallet) public view returns (bool) {
        return wallet == owner || permissions[id][wallet];
    }
}