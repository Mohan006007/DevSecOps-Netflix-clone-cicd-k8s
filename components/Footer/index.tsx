import styles from '../../styles/Footer.module.scss';
import { Github, Linkedin, Twitter } from '../../utils/icons';
import { IconType } from 'react-icons';

export default function Footer() {
  return (
    <div className={styles.footer}>
      <p>
        Made by{' '}
        <a href='https://github.com/Mohan006007' target='_blank' rel='noreferrer'>
          <b>DragOps</b>
        </a>
      </p>
      <div>
        <a href='https://linkedin.com/in/mohana-krishnan-06655a1b7/' className={styles.icon} target='_blank' rel='noreferrer'>
          <Linkedin />
        </a>
        <a href='https://twitter.com/DragOps0607' className={styles.icon} target='_blank' rel='noreferrer'>
          <Twitter />
        </a>
        <a href='https://github.com/Mohan006007' className={styles.icon} target='_blank' rel='noreferrer'>
          <Github />
        </a>
      </div>
    </div>
  );
}
