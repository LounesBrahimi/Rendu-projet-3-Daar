pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";

contract BuildCollective is Ownable {
  


  //------------------------------------------- User -----------------------------------------------------

  // Structure d'un compte utilisateur comptenant un username, une balance et un booleen indiquant si il est enregistrer
  struct User {
    string username;
    uint256 balance;
    bool registered;
  }

  // un mapping qui stock des utilisateurs et qui permet d'acceder à un utilisateur en lui introduisant une address
  mapping(address => User) private users;

  // Un evenement qui signale qu'un nouveau utilisateur c'est inscrit
  event UserSignedUp(address indexed userAddress, User indexed user);

  // Un modifier qui verifie qu'un utilisateur est deja enregistrer
  modifier userRegistred(address userAddress) {
    require(users[userAddress].registered);
    _;
  }

  // Un modifier qui verifie que le userName n'est pas vide
  modifier userNameNotEmpty(string memory username){
    require(bytes(username).length > 0);
    _;
  }

  // Un modifier qui verifie que la balance n'est pas negative
  modifier balanceNotNegative(uint256 balance){
    require(balance >= 0);
    _;
    }

  // Fonction view qui retourne un utilsateur inscrit en prenant une address en utilisant le mapping
  function user(address userAddress) public view userRegistred(userAddress) returns (User memory) {
    return users[userAddress];
  }

  // Fonction permettant d'inscrire un nouveau utilisateur
  function signUp(string memory username) public userNameNotEmpty(username) returns (User memory) {
    users[msg.sender] = User(username, 0, true);
    emit UserSignedUp(msg.sender, users[msg.sender]);
    return users[msg.sender];
  }

  // Fonction permettant d'augmenter la balance de l'utilisateur
  function addBalance(uint256 amount) public userRegistred(msg.sender) balanceNotNegative(amount) returns (bool) {
    users[msg.sender].balance += amount;
    return true;
  }

  //-------------------------------------------- Enterprise -----------------------------------------------------------

  // Structure d'une entreprise comptenant un nom, une balance, un proprietaire, les membres et une numero siren
  struct Enterprise {
    string name;
    string owner;
    uint256 balance;
    address[] members;
    uint16 siren;
    bool registered;
  }

  // un mapping qui stock les entreprises et qui permet d'acceder à une entreprise en lui introduisant l'adress de l'owner
  mapping(address => Enterprise) private entreprises;

  // Un evenement qui signale qu'une nouvelle entreprise a ete creee
  event EntrepriseSignedUp(address indexed ownerAddress, Enterprise indexed entreprise);

  // Un modifier qui verifie qu'une entreprise est bien creee
  modifier EntrepriseCreated(address ownerAddress) {
    require(entreprises[ownerAddress].registered);
    _;
  }

   // Fonction permettant d'enregistrer une nouvelle entreprise
  function signUpEntreprise(string memory _name, uint16 _siren) public userRegistred(msg.sender) userNameNotEmpty(_name) balanceNotNegative(_siren) returns (bool) {
    entreprises[msg.sender] = Enterprise(_name, users[msg.sender].username, 0, (new address[](500)), _siren, true);
    entreprises[msg.sender].members.push(msg.sender);
    emit EntrepriseSignedUp(msg.sender, entreprises[msg.sender]);
    return true;
  }

  // Fonction qui retourne une entereprise selon une address
  function getEntreprise(address ownerAddress) public view userRegistred(ownerAddress) EntrepriseCreated(ownerAddress) returns (Enterprise memory) {
    return entreprises[ownerAddress];
  }

  // Fonction retournant les membres d'une entreprise
  function getMembers(address ownerAddress) public view userRegistred(ownerAddress) EntrepriseCreated(ownerAddress) returns (address[] memory) {
    return entreprises[ownerAddress].members;
  }

  // Fonction permettant d'ajouter un nouveau membre a l'entreprise
  function addMember(address addressNewMember) public userRegistred(addressNewMember) EntrepriseCreated(msg.sender) returns (bool) {
    entreprises[msg.sender].members.push(addressNewMember);
    return true;
  }

  // Fonction permettant d'augmenter la balance de l'entreprise
  function addBalanceEntreprise(uint256 amount, address addressEntreprise) public EntrepriseCreated(addressEntreprise) balanceNotNegative(amount) returns (bool) {
    entreprises[addressEntreprise].balance += amount;
    return true;
  }

  //------------------------------------------- Projects -------------------------------------------------------

  // Structure d'un project comptenant un nom, une balance, un proprietaire, les membres et une numero siren
  struct Project {
    bytes32 id;
    string name;
    uint256 balance;
    address[] contributors;
    bool ownedByEnterprise;
    address payable walletForMoney;
    bool registered;
  }

    // Un mapping qui stock les projects et qui permet d'acceder à un project en lui introduisant l'adress de l'owner
  mapping(address => Project) private projects;

  // Un evenement qui signale qu'un nouveau projet a ete creee
  event ProjectCreated(address indexed ownerAddress, Project indexed project);

  // Un modifier qui verifie qu'un projet est bien creee
  modifier isProjectCreated(address ownerAddress) {
    require(projects[ownerAddress].registered);
    _;
  }

  // Un modifier qui verifie si un utilisateur est bien contributeur du projet
  modifier isContributor(address _user, address addressProject){
    uint arrayLength = projects[addressProject].contributors.length;
    bool satisfated = false;
    for (uint i=0; i<arrayLength; i++) {
      if (projects[addressProject].contributors[i] == _user){
        satisfated = true;
      }
    }
    require (satisfated == true);
    _;
  }

  // Fonction permettant de creer un projet
  function createProject(string memory _name, bool ownedByEnterprise, address payable wallet_) public userRegistred(msg.sender) userNameNotEmpty(_name) returns (bool) {
    projects[msg.sender] = Project(keccak256(abi.encodePacked(_name, msg.sender)),_name, 0, (new address[](500)), ownedByEnterprise, wallet_, true);
    projects[msg.sender].contributors.push(msg.sender);
    emit ProjectCreated(msg.sender, projects[msg.sender]);
    return true;
  }

  // Fonction qui permet d'envoyer de l'argent au project designe
  function GiveMoneyToProject(string memory _nameProject, address ownerAddress ) payable public isContributor(msg.sender, ownerAddress) userRegistred(ownerAddress) isProjectCreated(ownerAddress) userNameNotEmpty(_nameProject){
        require(keccak256(abi.encodePacked(_nameProject, ownerAddress)) == projects[ownerAddress].id);
        // Send Etherium to the wallet
        projects[ownerAddress].walletForMoney.transfer(msg.value);
    }
  

   //Fonction retournant les contributeurs d'un projet
  function getContributors(string memory _nameProject, address ownerAddress) public view userRegistred(ownerAddress) isProjectCreated(ownerAddress) userNameNotEmpty(_nameProject) returns (address[] memory) {
    require(keccak256(abi.encodePacked(_nameProject, ownerAddress)) == projects[ownerAddress].id);
    return projects[ownerAddress].contributors;
  }

  // Fonction permettant d'ajouter un nouveau contributeur au projet
  function addContributor(string memory _nameProject, address ownerAddress ,address addressNewContributor) public userRegistred(addressNewContributor) userRegistred(ownerAddress) isProjectCreated(ownerAddress) userNameNotEmpty(_nameProject)  returns (bool) {
    require(keccak256(abi.encodePacked(_nameProject, ownerAddress)) == projects[ownerAddress].id);
    projects[ownerAddress].contributors.push(addressNewContributor);
    return true;
  }

  // Fonction permettant d'augmenter la balance d'un projet
  function addBalanceProject(string memory _nameProject, address ownerAddress, uint256 amount) public userRegistred(ownerAddress) isProjectCreated(ownerAddress) userNameNotEmpty(_nameProject) balanceNotNegative(amount) returns (bool) {
    require(keccak256(abi.encodePacked(_nameProject, ownerAddress)) == projects[ownerAddress].id);
    projects[ownerAddress].balance += amount;
    return true;
  }

  //---------------------------------------- Fonctions utilitaires ---------------------------------------------

  // Fonction qui permet de convertir une address sous format string en une address
  function convertStrToAddress(string memory str) pure public returns (address _parsedAddress) {
    bytes memory tmp = bytes(str);
    uint160 iaddr = 0;
    uint160 b1;
    uint160 b2;
    for (uint i = 2; i < 2 + 2 * 20; i += 2) {
        iaddr *= 256;
        b1 = uint160(uint8(tmp[i]));
        b2 = uint160(uint8(tmp[i + 1]));
        if ((b1 >= 97) && (b1 <= 102)) {
            b1 -= 87;
        } else if ((b1 >= 65) && (b1 <= 70)) {
            b1 -= 55;
        } else if ((b1 >= 48) && (b1 <= 57)) {
            b1 -= 48;
        }
        if ((b2 >= 97) && (b2 <= 102)) {
            b2 -= 87;
        } else if ((b2 >= 65) && (b2 <= 70)) {
            b2 -= 55;
        } else if ((b2 >= 48) && (b2 <= 57)) {
            b2 -= 48;
        }
        iaddr += (b1 * 16 + b2);
    }
    return address(iaddr);
  }
}