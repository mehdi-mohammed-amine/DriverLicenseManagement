// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DriverLicenseManagement {
    struct User {
        string firstName;
        string lastName;
        uint256 birthYear;
        string bloodGroup;
        string nationalId;
        uint256 points;
        string violationDescription; // Description des violations
        bool registered;
    }

    struct Exam {
        string theoryExamDate;
        string practicalExamDate;
        bool passed;
    }

    struct Police {
        string name;
        string badgeNumber;
    }

    struct Examiner {
        string name;
        string department;
    }

    address public police;
    address public examiner; // Adresse de l'examinateur
    mapping(address => User) public users;
    mapping(address => Exam) public exams;
    mapping(address => Police) public policeRegistry;
    mapping(address => Examiner) public examinerRegistry;

    // Constructor avec l'adresse de la police et de l'examinateur
    constructor(address _police, address _examiner) {
        police = _police;
        examiner = _examiner;
    }

    // Modificateur pour s'assurer que seul la police peut appeler certaines fonctions
    modifier onlyPolice() {
        require(msg.sender == police, "Caller is not the police");
        _;
    }

    // Modificateur pour s'assurer que seul l'examinateur peut appeler certaines fonctions
    modifier onlyExaminer() {
        require(msg.sender == examiner, "Caller is not the examiner");
        _;
    }

    // Modificateur pour s'assurer que l'utilisateur est déjà enregistré
    modifier onlyRegisteredUser(address user) {
        require(users[user].registered, "User not registered");
        _;
    }

    // Fonction pour enregistrer un utilisateur
    function registerUser(
        string memory firstName,
        string memory lastName,
        uint256 birthYear,
        string memory bloodGroup,
        string memory nationalId
    ) public {
        require(!users[msg.sender].registered, "User already registered");
        users[msg.sender] = User({
            firstName: firstName,
            lastName: lastName,
            birthYear: birthYear,
            bloodGroup: bloodGroup,
            nationalId: nationalId,
            points: 40,
            violationDescription: "",
            registered: true
        });
    }

    // Fonction pour enregistrer une police
    event PoliceRegistered(address indexed policeAddress, string name, string badgeNumber);

    function registerPolice(
        string memory name,
        string memory badgeNumber
    ) public {
        require(bytes(policeRegistry[msg.sender].badgeNumber).length == 0, "Police already registered");

        policeRegistry[msg.sender] = Police(name, badgeNumber);
        emit PoliceRegistered(msg.sender, name, badgeNumber);
    }

    // Fonction pour enregistrer un examinateur
    event ExaminerRegistered(address indexed examinerAddress, string name, string department);

    function registerExaminer(
        string memory name,
        string memory department
    ) public {
        require(bytes(examinerRegistry[msg.sender].department).length == 0, "Examiner already registered");

        examinerRegistry[msg.sender] = Examiner(name, department);
        emit ExaminerRegistered(msg.sender, name, department);
    }

    // Fonction pour obtenir les informations d'un utilisateur
    function getUserInfo(address user)
        public
        view
        onlyRegisteredUser(user)
        returns (
            string memory,
            string memory,
            uint256,
            string memory,
            string memory,
            uint256
        )
    {
        User memory u = users[user];
        return (u.firstName, u.lastName, u.birthYear, u.bloodGroup, u.nationalId, u.points);
    }

    // Fonction pour signaler une violation par la police et réduire les points d'un utilisateur
    function reportViolation(address user, string memory description, uint pointsToDeduct) 
    public 
    onlyPolice 
    onlyRegisteredUser(user) 
{
    require(pointsToDeduct > 0, "Points to deduct must be greater than 0");
    require(users[user].points >= pointsToDeduct, "User does not have enough points");
    
    users[user].points -= pointsToDeduct;
    users[user].violationDescription = description;
}


    // Fonction pour planifier un examen pour un utilisateur, accessible uniquement à l'examinateur
    function scheduleExam(address user, string memory theoryExamDate, string memory practicalExamDate) public onlyExaminer {
        exams[user] = Exam({
            theoryExamDate: theoryExamDate,
            practicalExamDate: practicalExamDate,
            passed: false
        });
    }

    // Fonction pour obtenir les détails de l'examen d'un utilisateur
    function getExamDetails(address user)
        public
        view
        onlyRegisteredUser(user)
        returns (string memory, string memory, bool)
    {
        Exam memory e = exams[user];
        return (e.theoryExamDate, e.practicalExamDate, e.passed);
    }

    // Fonction pour approuver un examen pour un utilisateur, accessible uniquement à l'examinateur
    function approveExam(address user, bool passed) public onlyExaminer {
        require(users[user].points == 40, "User's points are not 40"); // Vérifier que les points sont à 40

        if (passed) {
            exams[user].passed = true; // Met à jour le statut de réussite de l'examen
        } else {
            exams[user].passed = false;
            users[user].points = 0; // Réduit les points à 0 si l'examen est échoué
        }
    }

    // Fonction pour obtenir les informations d'un utilisateur (accessible uniquement à la police)
    function getDriverInfo(address user)
        public
        view
        onlyPolice
        onlyRegisteredUser(user)
        returns (
            string memory,
            string memory,
            uint256,
            string memory,
            string memory,
            uint256,
            string memory
        )
    {
        User memory u = users[user];
        return (u.firstName, u.lastName, u.birthYear, u.bloodGroup, u.nationalId, u.points, u.violationDescription);
    }
}
