# Runtime Secrets

Production Docker Compose reads the JWT signing key from:

```text
secrets/jwt_secret.txt
```

Create it locally on the deployment host and do not commit it:

```sh
mkdir -p secrets
openssl rand -base64 64 > secrets/jwt_secret.txt
chmod 600 secrets/jwt_secret.txt
```

The backend also supports `JWT_SECRET` for local development, but production should prefer `JWT_SECRET_FILE` through Docker secrets.
