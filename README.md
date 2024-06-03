## 1. Introducción

### 1.1. Descripción del proyecto

Jenkins nos permite verificar algunos parámetros para realizar una imagen de Docker, si estas pruebas consiguen pasarse, la imagen se subirá a Dockerhub y se lanzará un despliegue en nuestro equipo.

### ¿Qué usaremos?
Se usarán varios contenedores para poner a prueba la capacidad de Docker además de la versatilidad que nos presta.

Usaremos como máquina un portátil Lenovo i5 sin tarjeta gráfica dedicada y 16 gb de ram.
Los contenedores a usar tienen los siguientes programas:
Jenkins
Prometheus
Grafana

Además dentro del contenedor Jenkins instalaremos Docker para probar el uso de contenedores dentro de contenedores.

Por lo que, el contenedor Jenkins sera el encargado de descargar los archivos de nuestro github y actualizarlos a la vez que ejecuta los procesos para que la aplicación lance el contenedor con todos los recursos necesarios.

### ¿Qué resultados esperamos?
Con esto se espera lograr aprender el uso de Plugins en Jenkins, sobre todo los plugins de Docker y de métricas.
Además, esperamos también aprender a manejar los JenkinsFile y pipelines de Jenkins. 


## 2. Introducción teórica

### 2.1. ¿Qué es Jenkins?
Jenkins es una aplicación de automatización de código abierto (Open source) escrito en Java. Está basado en Hudson, un software similar en uso.

¿Qué es lo que hace? Ayuda a la automatización del proceso de desarrollo de software mediante Integración continua además que facilita la entrega continua.
Tal y como hacía Hudson, admite herramientas de control de versiones como CVS, Subversion, Git, Mercurial, Perforce y Clearcase y ejecuta proyectos basados en Apache Ant y Maven, también puede ejecutar comandos en consolas y programas por lotes de Windows. Su desarrollador principal es Kohsuke Kawaguchi. Se publica bajo la licencia Mit.

En Jenkins trabajamos con Pipelines, pero ¿Qué son?
Un pipeline es una forma de trabajar en el mundo de los devops ya que nos permite una integración continua. Si usamos estos pipeline junto a Jenkins, podemos definir el ciclo de vida de una aplicación mediante código. Por consiguiente, podemos replicar los pasos con distintas aplicaciones para gestionar los cambios.
Su sintaxis sería la siguiente:

   * **Pipeline {}** Identificamos dónde empieza y termina el pipeline así como los pasos que tiene.

   * **Agent.** Especificamos cuando se ejecuta el pipeline. Uno de los comandos más utilizados es any, para ejecutar el pipeline siempre y cuando haya un ejecutor libre en Jenkins.

   * **Stages.** Bloque donde se definen una serie de estados a realizar dentro del pipeline.

   * **Stage.** Bloque que define una serie de tareas realizadas dentro del pipeline, por ejemplo: Build. test, deploy, etc. Podemos utilizar varios plugins en Jenkins para visualizar el estado o el progreso de estos estados.
   * **Steps.** Son todos los pasos a realizar dentro de un stage. Podemos definir uno o varios pasos.

   * **Step.** Es una tarea simple dentro del pipeline. Fundamentalmente es un paso donde se le dice a Jenkins qué hacer en un momento específico o paso del proceso. Por ejemplo, para ejecutar un comando en shell podemos tener un paso en el que tengamos la línea 'sh ls' para mostrar el listado de ficheros de una carpeta.


### 2.2 ¿Qué es Docker?

Docker, al igual que Jenkins, es Código abierto y su función principal es automatizar el despliegue de aplicaciones dentro de contenedores de software, proporciona una capa adicional de abstracción y automatiza la virtualización de las aplicaciones en múltiples sistemas operativos.
Se usan características de aislamiento de recursos del kernel Linux, como Cgroups y namespaces, lo que permite que los contenedores independientes se ejecuten dentro de una sola instancia de Linux, evitando la sobrecarga inicial y mantener las máquinas virtuales.

### 2.3 ¿Qué es un contenedor?

Los contenedores ofrecen un modo de empaquetar el código, las configuraciones y las dependencias de su aplicación en un único objeto. Los contenedores comparten sistema operativo instalado en el servidor y se ejecutan como procesos aislados de los recursos, lo que garantiza implementaciones rápidas, fiables y consistentes sea cual sea el entorno

### 2.4 ¿Qué es Prometheus?

Prometheus es una aplicación de software libre utilizada para la monitorización de eventos y alertas. Registra métricas en una base de datos de series temporales, permitiendo una alta dimensionalidad, construida utilizando un modelo de extracción HTTP. Prometheus ofrece consultas flexibles y alertas en tiempo real.

El proyecto está escrito en Go y licenciado bajo la Licencia Apache 2, con el código fuente disponible en GitHub. Es un proyecto graduado de la Cloud Native Computing Foundation, junto con Kubernetes y Envoy.

### 2.5 ¿Qué es Grafana?

Grafana es un software libre basado en la licencia de Apache 2.0, permite la visualización y el formato de datos métricos. Permite crear cuadros de mando y gráficos a partir de múltiples fuentes, incluidas bases de datos de series de tiempo. 

## 3. Herramientas usadas

En las máquinas que usamos necesitamos tener instalados:
Sudo
Algunos contenedores no traen instalado sudo, por lo que no sería recomendable para mayor confort instalarlo ya que permite ejecutar comandos de administrador en usuarios autorizados.
Docker
Instalarlo en cada máquina en la cual sea necesario para lanzar contenedores.
Nano
Como anteriormente pasaba con Sudo, algunos contenedores no traen Nano instalado y seria buena idea para más confort
Git
Necesario para nuestro desarrollo
netcat-traditional
Necesario para comandos de red
bc (calculadora)
Necesario para calcular algunos datos que hemos introducido en nuestro Pipeline
apache2-utils
Necesario para algunas utilidades que hemos introducido en nuestro pipeline


## 5. Preparación del equipo

Para preparar el equipo necesitaremos instalar Docker de primera mano.
En primera instancia si tenemos un Debian superior al 10 hemos introducido en nuestro pipeline


## 5. Preparación del equipo

Para preparar el equipo necesitaremos instalar Docker de primera mano.
En primera instancia si tenemos un Debian superior al 10 deberíamos poder instalar Docker haciendo un simple
apt install docker.io

Si no fuese posible tendríamos que seguir los siguientes pasos. para debian12
Primero comprobamos que no esta docker instalado y si lo esta lo desinstalamos
```
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

Después añadimos repositorios
```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

Instalamos
```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Añadimos usuario al grupo
```sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
```

y ya podría usarse el usuario en cuestión con docker sin necesidad de permisos de administrador.

Con esto listo damos paso a la construcción de la estructura del proyecto.



## 6. Desarrollo del Proyecto

Antes de comenzar, he de matizar que todo este proyecto puede hacerse sin docker y con máquinas físicas que tengan el software indicado, por lo que sí hay una manera de instalar el programa en físico en el equipo la obviaré ya que mi proyecto es solamente con docker y ver sus límites.
Jenkins:
Lo primero que debemos hacer es obtener la imagen de Jenkins, podemos buscarla en DockerHub. El comando para descargar la imágen es:
```
docker pull jenkins/jenkins
```
Además, necesitaremos una red para que nuestros contenedores se conecten entre sí la cual necesita el siguiente comando con docker:
```
docker network create jenkins
```
Para lanzar nuestra máquina podemos usar la siguiente línea como referencia que es la que usaremos. Dependiendo de tus necesidades puede cambiar algunas variables.
```
docker run -d --name jenkins --network jenkins -p 9080:8080 -p 50000:50000 -p 9070:9070 -v /opt/jenkins_home:/var/jenkins_home jenkins/jenkins
```
Si aparece un error en el cual no hay permisos para escribir podemos solucionarlo con la siguiente línea de comandos:

```
chown -R 1000 /opt/jenkins_home
```
Si nuestra máquina se ha lanzado correctamente, con un docker ps podremos ver que está correcto.

Ya podríamos acceder a nuestro jenkins con http://localhost:9080/ Que es el puerto que hemos usado para acceder. Tras esto podremos instalar los plugins


Hay 3 tipos de plugins que usaremos
Plugins de Docker:
Nos situaremos en el administrador de plugins de Jenkins y buscaremos  en disponibles los siguientes Plugins:
Docker
CloudBees Docker Hub/Registry Notification

Una vez instalados nos iremos a la configuración de Cloud y pondremos la siguiente ruta: unix:///var/run/docker.sock

Con estos plugins podremos lanzar comandos docker con nuestros pipeline y subir imágenes a dockerhub

Plugins Blue Ocean
Blue Ocean
Blue Ocean Pipeline Editor

Con estos plugins podremos ver funcionalidades extras de los Pipeline y ver los resultados de una manera más clara.

Plugins Prometheus:
Prometheus metrics
Con este plugin podremos comunicar jenkins con prometheus

Prometheus
Para instalar Prometheus via docker usaremos
```
docker run --name prometheus --network jenkins -p 9090:9090  -d --mount type=bind,source=/opt/prometheus.yml,target=/etc/prometheus/prometheus.yml prom/prometheus
```
Esto nos creara un contenedor docker en la red Jenkins, para que este conectado a nuestro jenkins, con el puerto 9090 habilitado. Podremos entrar a comprobarlo en http://localhost:9090/


Debemos tener el nuestro /opt/prometheus.yml una configuración que se le pasará al contenedor. Cualquier configuración básica de Prometheus sirve siempre que le añadamos este job para que cree métricas de jenkins
```
- job_name: 'jenkins'
  metrics_path: /prometheus
  static_configs:
    - targets: ['172.17.0.1:9080']
```

Grafana
Como hemos hecho con anterioridad necesitamos que grafana se conecte por la red Jenkins ademas de darle un puerto en este caso el 3000
```
docker run -d --name grafana --network jenkins -p 3000:3000 grafana/grafana
```
podremos entrar en http://localhost:3000


Una vez todo configurado en Grafana solo nos quedará añadir una fuente de datos, en este caso la de Prometheus. configurarla y añadir una tabla que en nuestro caso sera https://grafana.com/grafana/dashboards/9524 

Una vez planteado todo y los contenedores funcionando podemos empezar a crear nuestro entorno en Git

Entorno Git:
Vamos a necesitar crear un par de ramas, la primera la rama de pruebas y desarrollo para lanzar desde ahí los proyectos y una rama de producción para que se suba lo que funcione solamente.
Podemos crearla en nuestro github o con comandos git
Clonamos el repositorio y hacemos las ramas
```
git brach desarrollo
git branch produccion
git push -u origin desarrollo
git push -u origin produccion
```
En nuestro github habran varios archivos que se usaran de forma remota con nuestro jenkins.

Lo primero tendremos un dockerfile con la siguiente configuración
```
FROM php:apache-buster

RUN apt-get update && apt-get install -y bc \
    && docker-php-ext-install pdo pdo_mysql mysqli \
    && a2enmod rewrite

EXPOSE 80
COPY ./index.html /var/www/html
ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
```
Tambien necesitaremos el Jenkinsfile
```
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t tfg-jesus:test .'
            }
        }

        stage('Test') {
            steps {
                echo 'Testing...'

                sh 'docker run --rm --name appjenkins --network jenkins -d -p 9070:80 tfg-jesus:test'
                sh '/bin/nc -vz localhost 9070'
                
                sh label: '', script: '''#!/bin/bash
                    CPU=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\\([0-9.]*\\)%* id.*/\\1/" | awk \'{print 100 - $1}\')
                    max=90
                    if (( $(echo "$CPU > $max" | bc -l) )); then
                        echo "Sobrepasa el uso de CPU!"
                        exit 1
                    else
                        echo "CPU correcta."
                    fi
                '''
                
                sh label: '', script: '''#!/bin/bash
                    RamA=$(free -m | grep 'Mem' | awk '{print $2}')
                    RamU=$(free -m | grep 'Mem' | awk '{print $3}')
                    RamPorcentaje=$(echo "scale=1; $RamU / $RamA * 100" | bc)
                    max=90
                    if (( $(echo "$RamPorcentaje > $max" | bc -l) )); then
                        echo "Sobrepasa el uso de RAM! Esta usando el $RamPorcentaje por ciento"
                        exit 1
                    else
                        echo "RAM correcta."
                    fi
                '''
                
                sh 'ab -t 10 -c 200 http://localhost:9070/index.php | grep Requests'
            }
        }

        stage('Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-credentials', passwordVariable: 'gitid', usernameVariable: 'GITHUB_USER')]) {
                    sh 'rm -rf Jenkins-testing'
                    sh 'git clone --branch produccion https://github.com/JG-Alba/Jenkins-testing.git'
                    sh '''git config --global --add safe.directory /var/jenkins_home/workspace/prueba/Jenkins-testing
'''
                    sh 'cp -r Dockerfile Jenkins-testing && cd Jenkins-testing && git add . && git push https://${GITHUB_USER}:${gitid}@github.com/JG-Alba/Jenkins-testing.git'
                }
                withDockerRegistry([ credentialsId: "dockerhub", url: "" ]) {
	            	sh 'docker tag tfg-jesus:test soramatoi/tfg-jesus:stable'
		            sh 'docker push soramatoi/tfg-jesus:stable'
	            }
            }
        }
        stage('Deploy') {
            steps {
	                sh 'docker stop appjenkins'
	                sh 'docker pull soramatoi/tfg-jesus:stable'
	                sh 'docker run --rm --name wordjenkins --network jenkins -d -p 9070:80 soramatoi/tfg-jesus:stable'
        }
    }
    }
}
```

Este jenkinsfile se divide en:

### Fase Build
Se construira la imagen docker que los desarrolladores hayan cambiado

### Fase Test
Se desactiva la página, correremos una nueva para probar la CPU y la RAM y que no pasen del 90% y se mirara que esté activo el puerto 9070 (es el puerto que está usando la nueva máquina dentro del contenedor de jenkins) para hacer una prueba de rendimiento

### Fase Push
Si todas las pruebas son correctas, se subirán el dockerfile y el index.html a la rama de producción de nuestro github automáticamente y la imagen del contenedor se subirá a DockerHub

### Fase Deploy
Tras esto, se detendrá todo contenedor de pruebas y la pagina sera subida a producción, se hará un despliegue con la imagen que hemos subido a DockerHub


## 7. Conclusiones y dificultades

Para comenzar me gustaría empezar por las dificultades que he tenido. Jenkins y los pipeline es una herramienta compleja que al principio puede resultar costosa de entender y no es difícil entender a simple vista, pero tras observar y trabajarlo puedes ver que los pipeline acaban siendo comando de ejecución normales y corrientes de todo sistema linux pero lanzándolos con algunos comandos extra.

Da muy buenos resultados y puedes automatizarlo para que tus proyectos se actualicen a la vez que los cambias en tu github.

Es una muy buena herramienta que me gustaría investigar más a fondo ya que veo que tiene un muy buen potencial y creo que se podría aprovechar para grandes proyectos.

Si sacamos algún punto negativo, si queremos hacer un despliegue web con actualizaciones constantes hay formas más óptimas y rápidas que aprender Jenkins como Netifly que desde su web y un github puedes lanzar una página web en pocos segundos con una muy buena integración.



## 8. Referencias

[Instalación de Jenkins](https://www.jenkins.io/doc/book/installing/)

[Monitorización de Jenkins](https://medium.com/@eng.mohamed.m.saeed/monitoring-jenkins-with-grafana-and-prometheus-a7e037cbb376)

[Plugin de Docker](https://plugins.jenkins.io/docker-plugin/)

[Pipelines](https://sdos.es/blog/la-integracion-continua-actual-pasa-por-pipelines)
