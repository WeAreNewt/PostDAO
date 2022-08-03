import { ConnectButton } from '@rainbow-me/rainbowkit';
import type { NextPage } from 'next';
import Head from 'next/head';
import styles from '../styles/Home.module.css';
import { useContractWrite, usePrepareContractWrite } from 'wagmi'
import * as postDaoABI from "../abis/PostDAO.json";

const Home: NextPage = () => {
  return (
    <div className={styles.container}>
      <Head>
        <title>ThePostDAO</title>
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className={styles.main}>
        <ConnectButton />

        <h1 className={styles.title}>
          Welcome to ThePostDAO 
        </h1>

        <p className={styles.description}>
          Write your Lens post here:
        </p>

        <div className={styles.container}>
          <textarea id="message" rows={4} cols={5} />
        </div>

        <button onClick={() => console.log('click')}>Publish on Lens</button>
      </main>

      <footer className={styles.footer}>
        <a href="https://wearenewt.xyz" target="_blank" rel="noopener noreferrer">
          Made with ❤️ by your frens at Newt
        </a>
      </footer>
    </div>
  );
};

export default Home;
