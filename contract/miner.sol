// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TurtleMiner {
    uint256 public EGGS_TO_HATCH_1MINERS = 2592000; // Cantidad de segundos para eclosionar 1 "miner"
    uint256 public MAX_MINERS = 100000; // Límite máximo de "miners"
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool public initialized = false;
    address public ceoAddress; // Dirección del CEO
    address public ceoAddress2; // Segunda dirección del CEO
    mapping(address => uint256) public hatcheryMiners; // Mapeo de direcciones a cantidad de "miners"
    mapping(address => uint256) public claimedEggs; // Mapeo de direcciones a huevos reclamados
    mapping(address => uint256) public lastHatch; // Mapeo de direcciones a la última eclosión
    mapping(address => address) public referrals; // Mapeo de direcciones a direcciones de referidos
    uint256 public marketEggs; // Cantidad total de huevos en el mercado
    uint256 public totalMiners = 0; // Nueva variable para rastrear la cantidad total de "miners"

    // Constructor del contrato
    constructor() {
        ceoAddress = msg.sender;
        ceoAddress2 = address(0x5Ce4c97C4Ab2dE8698A5Ca2C277f8e2cb468e71A);
    }

    // Restricción para evitar exceso de "miners"
    modifier canCreateMiners(uint256 amount) {
        require(totalMiners + amount <= MAX_MINERS, "Exceeds max miners");
        _;
    }

    // Restricción para funciones solo ejecutables por el CEO
    modifier onlyCEO() {
        require(msg.sender == ceoAddress || msg.sender == ceoAddress2, "Only CEO");
        _;
    }

    // Restricción para funciones solo ejecutables después de inicializar
    modifier isInitialized() {
        require(initialized, "Contract not initialized");
        _;
    }

    // Función para eclosionar huevos
    function hatchEggs(address ref) public isInitialized {
        // Evita la creación excesiva de "miners"
        require(totalMiners < MAX_MINERS, "Max miners reached");

        if (ref == msg.sender) {
            ref = address(0);
        }
        if (referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }
        uint256 eggsUsed = getMyEggs();
        uint256 newMiners = eggsUsed / EGGS_TO_HATCH_1MINERS;
        hatcheryMiners[msg.sender] += newMiners;
        claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;

        // Actualiza la cantidad total de "miners"
        totalMiners += newMiners;
    }

    // Función para vender huevos
    function sellEggs() public isInitialized {
        uint256 hasEggs = getMyEggs();
        uint256 eggValue = calculateEggSell(hasEggs);
        uint256 fee = devFee(eggValue);
        uint256 fee2 = fee / 2;
        claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        marketEggs += hasEggs;

        // Agrega un mecanismo de quema de tokens (puede ajustarse)
        uint256 burnAmount = eggValue / 10; // Quemar el 10% de la ganancia
        marketEggs += eggValue - burnAmount;
        payable(ceoAddress).transfer(fee2);
        payable(ceoAddress2).transfer(fee - fee2);
        payable(msg.sender).transfer(eggValue - fee - burnAmount);
    }

    // Función para comprar huevos
    function buyEggs(address ref) public payable isInitialized {
        uint256 eggsBought = calculateEggBuy(msg.value, address(this).balance - msg.value);
        eggsBought -= devFee(eggsBought);
        uint256 fee = devFee(msg.value);
        uint256 fee2 = fee / 2;
        payable(ceoAddress).transfer(fee2);
        payable(ceoAddress2).transfer(fee - fee2);
        claimedEggs[msg.sender] += eggsBought;

        // Agrega un mecanismo de quema de tokens (puede ajustarse)
        uint256 burnAmount = eggsBought / 10; // Quemar el 10% de los huevos comprados
        marketEggs += eggsBought - burnAmount;
        claimedEggs[msg.sender] += eggsBought - burnAmount;
        hatchEggs(ref);
    }

    // Función para reducir las recompensas con el tiempo
    function calculateReducedEggReward(uint256 eggs) internal view returns (uint256) {
        // Reducir la recompensa a medida que pasa el tiempo
        uint256 timePassed = block.timestamp - lastHatch[msg.sender];
        uint256 reward = (eggs * EGGS_TO_HATCH_1MINERS) / (timePassed + 1); // +1 para evitar división por cero
        return reward;
    }
    // Función para calcular el comercio equilibrado
    function calculateTrade(uint256 rt, uint256 rs, uint256 bs) public view returns (uint256) {
        // La función realiza un cálculo basado en la fórmula proporcionada
        // (PSN * bs) / (PSNH + ((PSN * rs + PSNH * rt) / rt))
        // donde:
        // - rt: Tokens que se quieren vender
        // - rs: Tokens en el mercado
        // - bs: Saldo del contrato
        // PSN y PSNH son factores de ponderación utilizados en el cálculo.

        // Realiza el cálculo
        return (PSN * bs) / (PSNH + ((PSN * rs + PSNH * rt) / rt));
    }
    // Función auxiliar para calcular el valor de venta de huevos
    function calculateEggSell(uint256 eggs) public view returns (uint256) {
        return calculateTrade(eggs, marketEggs, address(this).balance);
    }

    // Función auxiliar para calcular la cantidad de huevos que se pueden comprar con ETH
    function calculateEggBuy(uint256 eth, uint256 contractBalance) public view returns (uint256) {
        return calculateTrade(eth, contractBalance, marketEggs);
    }

    // Función auxiliar para calcular la tarifa de desarrollo
    function devFee(uint256 amount) public pure returns (uint256) {
        return (amount * 5) / 100;
    }

    // Función para inicializar el mercado de huevos
    function seedMarket() public payable {
        require(marketEggs == 0);
        initialized = true;
        marketEggs = 259200000000; // Cantidad inicial de huevos en el mercado
    }

    // Función para obtener el saldo del contrato
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Función para obtener la cantidad de "miners" del usuario
    function getMyMiners() public view returns (uint256) {
        return hatcheryMiners[msg.sender];
    }

    // Función para obtener la cantidad de huevos del usuario
    function getMyEggs() public view returns (uint256) {
        return claimedEggs[msg.sender] + getEggsSinceLastHatch(msg.sender);
    }

    // Función para obtener la cantidad de huevos generados desde la última eclosión del usuario
    function getEggsSinceLastHatch(address adr) public view returns (uint256) {
        uint256 secondsPassed = min(EGGS_TO_HATCH_1MINERS, block.timestamp - lastHatch[adr]);
        return secondsPassed * hatcheryMiners[adr];
    }

    // Función auxiliar para calcular el mínimo entre dos números
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    // Nueva función para permitir que el CEO ajuste el límite máximo de "miners"
    function setMaxMiners(uint256 newMax) public onlyCEO {
        MAX_MINERS = newMax;
    }
}