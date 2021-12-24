import React from 'react';
import clsx from 'clsx';
import styles from './HomepageFeatures.module.css';

const FeatureList = [
  {
    title: 'Not need to describe the schemes',
    Svg: require('../../static/img/burger.svg').default,
    description: (
      <>
        You do not need to manually describe the scheme yourself.
        All you need to do is declare the data type for the form.
      </>
    ),
  },
  {
    title: 'Match type to field templates',
    Svg: require('../../static/img/printer.svg').default,
    description: (
      <>
       Using widgets and a template will save you the hassle of constantly editing components.
      </>
    ),
  },
  {
    title: 'Easy API',
    Svg: require('../../static/img/lazy.svg').default,
    description: (
      <>
       Just use decorators (ppx) on the fields to give them a special look or set the meta
      </>
    ),
  },
];

function Feature({Svg, title, description}) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center">
        <Svg className={styles.featureSvg} alt={title} />
      </div>
      <div className="text--center padding-horiz--md">
        <h3>{title}</h3>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
