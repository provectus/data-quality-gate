FROM data-test:latest
ENV ENVIRONMENT=local
ENV REPORTS_WEB=test
ENV AWS_ACCESS_KEY_ID=test
ENV AWS_SECRET_ACCESS_KEY=test
ENV AWS_DEFAULT_REGION=us-east-1
ENV REDSHIFT_DB=test
ENV REDSHIFT_SECRET=test
ENV S3_HOST=localhost
ENV S3_PORT=9000
ENV BUCKET=test-bucket
RUN pip3 install pytest==7.3.1 moto==4.1.6
COPY ./test*.py ./
ENTRYPOINT ["pytest", "-qvs"]