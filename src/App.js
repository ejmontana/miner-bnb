import React, { useEffect } from "react";
import { useWeb3React } from "@web3-react/core";
import { injected } from "./wallet/connectors"; 
import Web3 from "web3";
import { abiContract } from "./abiContract";

const web3 = new Web3(Web3.givenProvider);
const MyContract = new web3.eth.Contract(
  abiContract,
  "0x4b5C708849D26A588244fcB2A5784d5eAad998CE"
);

function MyComponent() {
  //Web3 config
  const { account, active, library, activate, deactivate } = useWeb3React();

  const BuyEgga = async (pBnb, pAccount) => {
    const valueInWei = Web3.utils.toWei(pBnb, "ether");
    MyContract.methods
      .buyEggs("0xd593E54F98fe5956c9AB2720a85b6aF2d1E5d9B0")
      .send({ from: pAccount, value: valueInWei })
      .then((result) => {
        console.log(result);
      })
      .catch((err) => {
        console.log(err);
      });
  };
  
  const connect = async () => {
    try {
      await activate(injected);
      localStorage.setItem("isWalletConnected", true);
    } catch (ex) {
      console.log(ex);
    }
  };

 

  useEffect(() => {
    connect();
  }, []);

  return (
    <div>
      {active ? <p>Connected Account: {account} <button onClick={() =>BuyEgga('0.001', account)} >Hola</button> </p> : <p>Not connected</p>}
    </div>
  );
}

export default MyComponent;
