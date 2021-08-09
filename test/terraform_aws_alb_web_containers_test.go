package test

import (
	"crypto/tls"
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestTerraformAwsAlbWebContainersSimpleHttp(t *testing.T) {
	t.Parallel()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/simple")

	testName := fmt.Sprintf("terratest-%s", strings.ToLower(random.UniqueId()))
	loggingBucket := fmt.Sprintf("%s-logs", testName)
	loggingPrefix := fmt.Sprintf("alb/%s", testName)
	awsRegion := "us-west-2"
	vpcAzs := aws.GetAvailabilityZones(t, awsRegion)[:3]

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"test_name":   testName,
			"logs_bucket": loggingBucket,
			"logs_prefix": loggingPrefix,
			"vpc_azs":     vpcAzs,
			"region":      awsRegion,
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	dnsEndpoint := terraform.Output(t, terraformOptions, "dns_endpoint")
	testURL := fmt.Sprintf("https://%s/", dnsEndpoint)
	expectedText := "Hello, world!"
	tlsConfig := tls.Config{
		MinVersion: tls.VersionTLS12,
	}
	maxRetries := 10
	timeBetweenRetries := 10 * time.Second

	http_helper.HttpGetWithRetry(t, testURL, &tlsConfig, 200, expectedText, maxRetries, timeBetweenRetries)
}

func TestTerraformAwsAlbWebContainersSimpleHttpDisabledLogs(t *testing.T) {
	t.Parallel()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/simple")

	testName := fmt.Sprintf("terratest-%s", strings.ToLower(random.UniqueId()))
	awsRegion := "us-west-2"
	vpcAzs := aws.GetAvailabilityZones(t, awsRegion)[:3]

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"test_name":   testName,
			"logs_bucket": "", // this is the option being tested
			"logs_prefix": "",
			"vpc_azs":     vpcAzs,
			"region":      awsRegion,
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	dnsEndpoint := terraform.Output(t, terraformOptions, "dns_endpoint")
	testURL := fmt.Sprintf("https://%s/", dnsEndpoint)
	expectedText := "Hello, world!"
	tlsConfig := tls.Config{
		MinVersion: tls.VersionTLS12,
	}
	maxRetries := 10
	timeBetweenRetries := 10 * time.Second

	http_helper.HttpGetWithRetry(t, testURL, &tlsConfig, 200, expectedText, maxRetries, timeBetweenRetries)
}
