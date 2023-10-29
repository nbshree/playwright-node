node('jnlp-web') {
  // 镜像仓库前缀
  def NAMESPACE = "container_group/images"
  def deploymentNamespace= "pt-e2e-playwright"
  def serviceName= "pt-e2e-playwright"
  def tag= "latest"
  def SERVER_URL = "registry.powertradepro.com"
  def full_image_name = ""
  def FULL_ADDRESS = "${SERVER_URL}/${NAMESPACE}"
  def DEPLOYMENT_NODE_IP = "192.168.125.144"
  def DEPLOYMENT_NODE_SSH_PORT = "22"
  def REGISTRY_AUTH_ID = 'gitlab-registry-auth'
  def DEPLOY_SSH_AUTH_ID = 'k8s-deploy-ssh-auth'

  def buildId = ""
  def skipDeploy = false

  def build_env = "dev"
  def ref = "refs/heads/master"


  stage('code pull') {
    waitUntil {
      try{
        buildId = currentBuild.number.toString()
        echo buildId
        echo ref
        scmVars = checkout([
            $class: 'GitSCM',
            branches: [[name: ref]],
            doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
            extensions: scm.extensions,
            userRemoteConfigs: scm.userRemoteConfigs
        ])
        script {
          echo "pull successfully"
        }
        true
      }catch(error){
        echo "Retry"
        false
      }
    }
  }
  stage('docker login') {
    waitUntil {
      try{
          withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: REGISTRY_AUTH_ID, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
            script {
                sh (returnStdout: false, script: "docker login --username=${USERNAME} --password=${PASSWORD} ${SERVER_URL}"  )
            }
        }
        true
      }catch(error){
        echo "Retry"
        false
      }
    }
  }
  stage('build in docker') {
    script {
      echo "begin build in docker"
      echo buildId
        full_image_name= "${FULL_ADDRESS}/${serviceName}:${tag}"
        if (ref == "refs/heads/release"){
          sh (returnStdout: false, script: "docker build --build-arg buildId=${buildId} -t ${full_image_name} -f dockerfile.release.backup ." )
        }
        else if ( ref == "refs/tags/maintain"){
          sh (returnStdout: false, script: "docker build --build-arg buildId=${buildId} -t ${full_image_name} -f dockerfile.maintain ." )
        }
        else if ( ref.startsWith("refs/tags/")){
          sh (returnStdout: false, script: "docker build --build-arg buildId=${tag} -t ${full_image_name} -f dockerfile.master.backup ." )
        } else {
          sh (returnStdout: false, script: "docker build --build-arg buildId=${buildId} -t ${full_image_name} ." )
        }
        echo "end build in docker"
    }
  }
  stage('push to registry') {
    if(skipDeploy){
      echo "skip deploy"
    }
    else{
      waitUntil {
        try{
          script {
            echo "begin push to registry"

            sh (returnStdout: false, script: "docker push ${full_image_name}"  )

            echo "end push to huawei yun registry"
          }
          true
        }catch(error){
          echo "Retry"
          false
        }
      }
    }
  }
  stage('deployment') {
    if(skipDeploy){
      echo "skip deploy"
    }
    else{
      waitUntil {
        try{
            withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: DEPLOY_SSH_AUTH_ID, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
              script {
                echo "begin deployment by ssh"
                def scripts="sshpass -p '${PASSWORD}' ssh -o StrictHostKeyChecking=no ${USERNAME}@${DEPLOYMENT_NODE_IP} 'kubectl --insecure-skip-tls-verify -n ${deploymentNamespace} set env deployments ${serviceName} build_version=${buildId}' "
                sh (returnStdout: false, script: scripts  )

                echo "end deployment by ssh"
              }
            }

          true
        }
        catch(error){
          echo "Retry"
          false
        }
      }
    }
  }
}
