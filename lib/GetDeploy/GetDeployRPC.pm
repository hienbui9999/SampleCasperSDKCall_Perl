=comment
This class handles info_get_deploy RPC call
=cut

package GetDeploy::GetDeployRPC;
use JSON qw( decode_json );
use JSON qw( encode_json );

use HTTP::Request;
use LWP::UserAgent;
use Common::ErrorException;
use GetDeploy::Deploy;
use Common::ConstValues;
use GetDeploy::DeployHeader;
use GetDeploy::ExecutableDeployItem::ExecutableDeployItem;
use GetDeploy::GetDeployResult;

sub new {
	my $class = shift;
	my $self = {_url=>shift};
	bless $self, $class;
	return $self;
}

# get-set method for _url
sub setUrl {
	my ($self,$value) = @_;
	$self->{_url} = $value if defined ($value);
	return $self->{_url};
}
sub getUrl {
	my ($self) = @_;
	return $self->{_url};
}
=comment
	 * This function does info_get_deploy RPC call
	 * This function initiate the process of sending POST request with given parameter in JSON string format
     * The input parameterStr is used to send to server as parameter of the POST request to get the result back.
     * The input parameterStr is somehow like this:
     * {"id" : 1,"method" : "info_get_deploy","params" : {"deploy_hash" : "6e74f836d7b10dd5db7430497e106ddf56e30afee993dd29b85a91c1cd903583"},"jsonrpc" : "2.0"}
     * The parameterStr is generated by the GetDeployParams class, declared in file GetDeployParams.pm
     * Then the GetDeployResult is retrieved by parsing JsonObject result
     * If the result is error,  then an exception is thrown
     * Else the GetDeployResult is taken by parsing the retrieving JsonObject
=cut
sub getDeployResult {
	my ($self) = @_;
	my @list = @_;
	my $uri = $self->{_url};
	if($uri) {
	} else {
		$uri = $Common::ConstValues::TEST_NET;
	}
	my $json = $list[1];
	my $req = HTTP::Request->new( 'POST', $uri );
	$req->header( 'Content-Type' => 'application/json');
	$req->content( $json );
	my $lwp = LWP::UserAgent->new;
	my $response = $lwp->request( $req );
	if ($response->is_success) {
	    my $d = $response->decoded_content;
	    my $decoded = decode_json($d);
	    my $errorCode = $decoded->{'error'}{'code'};
	    if($errorCode) {
	    	my $errorException = new Common::ErrorException();
	    	$errorException->setErrorCode($errorCode);
	    	$errorException->setErrorMessage($decoded->{'error'}{'message'});
	    	return $errorException;
	    } else {
	    	my $deployResult = new GetDeploy::GetDeployResult();
	    	$deployResult = GetDeploy::GetDeployResult->fromJsonObjectToGetDeployResult($decoded->{'result'});
		    return $deployResult;
	    }
	}
	else {
	    die $response->status_line;
	}
}
1;