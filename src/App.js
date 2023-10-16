import React, { useEffect } from "react";
import { useWeb3React } from "@web3-react/core";
import { injected } from "./wallet/connectors";
import Web3 from "web3";
import { abiContract } from "./abiContract";
import {
  AppBar,
  Box,
  IconButton,
  Toolbar,
  Typography,
  Button,
  Grid,
  Paper,
  Container,
} from "@mui/material";
import { styled } from "@mui/material/styles";
import img1 from "./img/img1.jpg";

const web3 = new Web3(Web3.givenProvider);
const MyContract = new web3.eth.Contract(
  abiContract,
  "0x4b5C708849D26A588244fcB2A5784d5eAad998CE"
);

function MyComponent() {
  //Web3 config
  const { account, active, library, activate, deactivate } = useWeb3React();

  const BuyEgga = async (pBnb) => {
    const valueInWei = Web3.utils.toWei(pBnb, "ether");
    MyContract.methods
      .buyEggs("0xd593E54F98fe5956c9AB2720a85b6aF2d1E5d9B0")
      .send({ from: account, value: valueInWei })
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

  const Item = styled(Paper)(({ theme }) => ({
    backgroundColor: theme.palette.mode === "dark" ? "#1A2027" : "#fff",
    ...theme.typography.body2,
    padding: theme.spacing(1),
    textAlign: "center",
    color: theme.palette.text.secondary,
  }));
  const gridContainerStyle = {
    display: "flex",
    justifyContent: "center", // Centraliza horizontalmente
    alignItems: "center", // Centraliza verticalmente
    height: "80vh", // Isso faz com que o contêiner ocupe a altura total da janela
  };
  return (
    <>
      <AppBar position="static">
        <Toolbar>
          <IconButton
            size="large"
            edge="start"
            color="inherit"
            aria-label="menu"
            sx={{ mr: 2 }}
          ></IconButton>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            News
          </Typography>
          <Button color="inherit">Login</Button>
        </Toolbar>
      </AppBar>
      <Container fixed>
        <div style={gridContainerStyle}>
          <Grid container spacing={3}>
            <Grid item xs={4}>
              <img src={img1} alt="turtle miner" style={{ width: "100%", height: "386px", paddingLeft: '120px' }} />
            </Grid>
            <Grid item xs={6} style={{paddingLeft: '120px'}}>
              <Paper style={{ padding: "16px", height: "22rem" }}>
              <center>

                <h1>Trutle Miner</h1>
                </center>
                <h2>
                  {" "}
                  🥚 ¿Quieres ser parte de la acción? <br /> Es fácil:
                  <br /> 
                  🐣 Eclosiona tus huevos y genera Miners.
                  <br />
                  💰 Vende tus huevos por BNB.
                  <br />
                  💸 Compra más huevos y acelera tus ganancias.
                  <br />
                </h2>
              </Paper>
           
            </Grid>
          </Grid>
        </div>
      </Container>
    </>
  );
}

export default MyComponent;
