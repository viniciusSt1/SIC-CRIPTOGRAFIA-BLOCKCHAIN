// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Aposta {
    address private owner;
    bytes32 private hash = 0xc8d33fa44a791ec6e46cabe3597cb9800c86811167505e7b77e65b0532d754f5; // num | salt ambos em hex
    bool private finalizado;

    mapping(address => uint256) private valorApostado;
    mapping(address => uint256) private numeroAposta;
    address[] private participantes;

    constructor() {
        owner = msg.sender;
        finalizado = false;
    }

    // Função para apostar
    function apostar(uint256 num) public payable {
        require(!finalizado, "Aposta finalizada");
        require(num >= 1 && num <= 4, "Numero deve estar entre 1 e 4");
        require(msg.value > 0, "Aposta precisa ser maior que zero");

        if (valorApostado[msg.sender] == 0) {
            participantes.push(msg.sender);
        }

        valorApostado[msg.sender] += msg.value;
        numeroAposta[msg.sender] = num; // Atualiza o número apostado pelo jogador
    }

    // Função para doar ETH ao contrato
    function doar() public payable {}

    // Ver montante total do contrato
    function ver_montante() public view returns (uint256) {
        return address(this).balance;
    }

    // Finalizar aposta e distribuir prêmios (conceito)
    function finalizar_aposta(uint256 numero, uint256 salt) public returns (uint256) {
        require(msg.sender == owner, "Somente o dono pode finalizar");
        require(!finalizado, "Aposta ja finalizada");

        uint256 montanteApostasVencedoras = 0;

        for (uint i = 0; i < participantes.length; i++) {
            if (numeroAposta[participantes[i]] == numero) {
                montanteApostasVencedoras += valorApostado[participantes[i]];
            }
        }

        require(montanteApostasVencedoras > 0, "Nenhum vencedor - nada a distribuir");

        uint256 montantePremio = address(this).balance;

        for (uint i = 0; i < participantes.length; i++) {
            address vencedor = participantes[i];
            if (numeroAposta[vencedor] == numero) {
                uint256 premio = (valorApostado[vencedor] * montantePremio) / montanteApostasVencedoras;
                payable(vencedor).transfer(premio);
            }
        }

        finalizado = true;
        return salt;
    }
}
