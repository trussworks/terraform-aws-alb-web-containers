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

func TestTerraformAwsAlbWebContainersSimpleHttpWithLogging(t *testing.T) {
	t.Parallel()

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, "../", "examples/simple")

	testName := fmt.Sprintf("terratest-%s", strings.ToLower(random.UniqueId()))
	loggingBucket := fmt.Sprintf("%s-logs", testName)
	awsRegion := "us-west-2"
	vpcAzs := aws.GetAvailabilityZones(t, awsRegion)[:3]

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"test_name":   testName,
			"logs_bucket": loggingBucket,
			"vpc_azs":     vpcAzs,
			"region":      awsRegion,
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply`
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	/*
		We need to apply twice because of the current bug with `dynamic` blocks in terraform `aws` provider:
		Error: Provider produced inconsistent final plan

		When expanding the plan for module.alb.aws_lb.main to include new values
		learned so far during apply, provider "registry.terraform.io/hashicorp/aws"
		produced an invalid new value for .access_logs[0].bucket: was
		cty.StringVal(""), but now cty.StringVal("terratest-rbbbb7-logs").

		This is a bug in the provider, which should be reported in the provider's own
		issue tracker.
		https://github.com/terraform-providers/terraform-provider-aws/issues/10297
		https://github.com/terraform-providers/terraform-provider-aws/issues/7987
		https://github.com/hashicorp/terraform/issues/20517
	*/
	if err != nil {
		terraform.Apply(t, terraformOptions)
	}

	// Run `terraform output` to get the value of an output variable
	dnsEndpoint := terraform.Output(t, terraformOptions, "dns_endpoint")
	testURL := fmt.Sprintf("https://%s/", dnsEndpoint)
	expectedText := "Hello, world!"
	tlsConfig := tls.Config{}

	maxRetries := 10
	timeBetweenRetries := 10 * time.Second

	http_helper.HttpGetWithRetry(t, testURL, &tlsConfig, 200, expectedText, maxRetries, timeBetweenRetries)
}

func TestTerraformAwsAlbWebContainersSimpleHttpWithoutLogging(t *testing.T) {
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
			"logs_bucket": "",
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
	tlsConfig := tls.Config{}

	maxRetries := 10
	timeBetweenRetries := 10 * time.Second

	http_helper.HttpGetWithRetry(t, testURL, &tlsConfig, 200, expectedText, maxRetries, timeBetweenRetries)
}
