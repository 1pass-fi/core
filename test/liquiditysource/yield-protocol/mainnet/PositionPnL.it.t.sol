//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import "./WithYieldFixtures.sol";

import "src/libraries/DataTypes.sol";
import "src/dependencies/Uniswap.sol";
import {ModifyCostResult} from "src/libraries/DataTypes.sol";

contract YieldMainnetPnLUSDCTest is
    WithYieldFixtures(constants.yETHUSDC2303, constants.FYETH2303, constants.FYUSDC2303)
{
    using SignedMath for int256;
    using SafeCast for int256;
    using YieldUtils for PositionId;

    function setUp() public override {
        super.setUp();
        stubPriceWETHUSDC(1000e6);
    }

    function testOpenAndCloseProfitableLongUSDC() public {
        (PositionId positionId,) = _openPosition(20 ether);

        // Move the market
        skip(4.5 days);
        _update(yieldInstrument.basePool);
        skip(0.5 days);
        stubPriceWETHUSDC(1500e6);

        // Close position
        _closePosition(positionId);
    }

    function testOpenAndCloseLossMakingLongUSDC() public {
        (PositionId positionId,) = _openPosition(20 ether);

        // Move the market
        skip(4.5 days);
        _update(yieldInstrument.basePool);
        skip(0.5 days);
        stubPriceWETHUSDC(960e6);

        // Close position
        _closePosition(positionId);
    }

    // The version of the code is different from what's deployed, so we need to hack a bit to call the old function
    function _update(IPool pool) internal {
        (bool success,) = address(poolOracle).call(abi.encodeWithSelector(0x7b46c54f, address(pool)));
        assertTrue(success, "PoolOracle#updatePool");
    }
}
