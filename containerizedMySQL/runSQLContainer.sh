# Create the database client which will be used to reach the database
podman run -d --name db_client --volume /etc/yum.repos.d:/etc/yum.repos.d registry.access.redhat.com/ubi9/ubi-minimal@sha256:582e18f13291d7c686ec4e6e92d20b24c62ae0fc72767c46f30a69b1a6198055 sleep infinity

#  Run the MySQL container with basic credentials
podman run -d --name db_01 --env MYSQL_USER=${1} --env MYSQL_PASSWORD=${2} \
--env MYSQL_DATABASE=${3} --env MYSQL_ROOT_PASSWORD=${4} \
--volume ~/database:/var/lib/mysql:Z --port ${5}:${6} \
registry.redhat.io/rhel8/mysql-80@sha256:ae45771ff311958d6907c82773c3b701933fa6039f865e24fa30f96bb1e630e0


