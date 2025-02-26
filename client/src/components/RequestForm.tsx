import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useToast } from "@/hooks/use-toast";

interface RequestFormProps {
  onSubmit: (request: any, apiKey: string) => void;
  isLoading: boolean;
}

const RequestForm = ({ onSubmit, isLoading }: RequestFormProps) => {
  const { toast } = useToast();
  const [endpoint, setEndpoint] = useState("chat-completions");
  const [apiKey, setApiKey] = useState("");
  const [requestBody, setRequestBody] = useState(JSON.stringify({
    "model": "gpt-3.5-turbo",
    "messages": [
      {"role": "system", "content": "You are a helpful financial assistant."},
      {"role": "user", "content": "What is the best way to save for retirement?"}
    ],
    "temperature": 0.7,
    "max_tokens": 300
  }, null, 2));

  const formatJson = () => {
    try {
      const parsed = JSON.parse(requestBody);
      setRequestBody(JSON.stringify(parsed, null, 2));
    } catch (error) {
      toast({
        title: "Invalid JSON",
        description: "The request body is not valid JSON.",
        variant: "destructive"
      });
    }
  };

  const handleSubmit = () => {
    if (!apiKey) {
      toast({
        title: "API Key Required",
        description: "Please enter an API key to make a request.",
        variant: "destructive"
      });
      return;
    }

    try {
      const requestData = JSON.parse(requestBody);
      onSubmit(requestData, apiKey);
    } catch (error) {
      toast({
        title: "Invalid JSON",
        description: "The request body is not valid JSON.",
        variant: "destructive"
      });
    }
  };

  return (
    <Card>
      <CardHeader className="bg-[#F7F7F8] border-b border-[#E5E5E5]">
        <CardTitle>Test Request</CardTitle>
      </CardHeader>
      <CardContent className="p-4">
        <div className="space-y-4">
          <div>
            <Label htmlFor="endpoint-select">Endpoint</Label>
            <Select 
              value={endpoint} 
              onValueChange={setEndpoint}
            >
              <SelectTrigger id="endpoint-select" className="w-full">
                <SelectValue placeholder="Select endpoint" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="chat-completions">POST /api/v1/chat/completions</SelectItem>
                <SelectItem value="message-history">GET /api/v1/messages</SelectItem>
                <SelectItem value="models">GET /api/v1/models</SelectItem>
              </SelectContent>
            </Select>
          </div>
          
          <div>
            <Label htmlFor="api-key">API Key</Label>
            <Input 
              id="api-key" 
              type="text" 
              placeholder="Enter your API key" 
              value={apiKey}
              onChange={(e) => setApiKey(e.target.value)}
            />
          </div>
          
          <div>
            <div className="flex justify-between items-center mb-1">
              <Label htmlFor="request-body">Request Body</Label>
              <Button 
                variant="outline" 
                size="sm"
                onClick={formatJson}
              >
                Format
              </Button>
            </div>
            <Textarea 
              id="request-body" 
              value={requestBody}
              onChange={(e) => setRequestBody(e.target.value)}
              className="font-mono h-64"
            />
          </div>
          
          <div className="flex justify-end">
            <Button 
              onClick={handleSubmit}
              disabled={isLoading}
              className="bg-primary hover:bg-primary/90"
            >
              {isLoading ? "Sending..." : "Send Request"}
            </Button>
          </div>
        </div>
      </CardContent>
    </Card>
  );
};

export default RequestForm;
