const fightWar = artifacts.require("FightWar");
const compoundWeapon = artifacts.require("CompoundWeapon");
const gameCoin = artifacts.require("GameCoin");
const weaponCore = artifacts.require("WeaponCore");
const tradeMarket = artifacts.require("TradeMarket");


var fwContract;
module.exports = function (deployer) {
    deployer.deploy(fightWar)
        .then(() => fightWar.deployed())
        .then(async (instance) => {
            fwContract = instance
            await deployer.deploy(compoundWeapon)
        }
        )
        .then(() => compoundWeapon.deployed())
        .then(() => deployer.deploy(gameCoin, "GameCoinToken", "GCT"))
        .then(() => gameCoin.deployed())
        .then(async () => {
            fwContract.setCoinAddress(gameCoin.address);
            await deployer.deploy(weaponCore, compoundWeapon.address, gameCoin.address)
        }
        )
        .then(() => weaponCore.deployed())
        .then(() => deployer.deploy(tradeMarket, weaponCore.address, 20))
}
