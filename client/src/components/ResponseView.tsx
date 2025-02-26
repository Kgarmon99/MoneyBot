import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { InfoIcon } from "lucide-react";
import CodeBlock from "./CodeBlock";

interface ResponseViewProps {
  response: any | null;
  error: Error | null;
  status: number | null;
  isLoading: boolean;
}

const ResponseView = ({ response, error, status, isLoading }: ResponseViewProps) => {
  const getStatusColor = (status: number | null) => {
    if (!status) return "bg-gray-500";
    if (status >= 200 && status < 300) return "bg-primary";
    if (status >= 400 && status < 500) return "bg-yellow-500";
    if (status >= 500) return "bg-red-500";
    return "bg-gray-500";
  };

  return (
    <Card>
      <CardHeader className="bg-[#F7F7F8] border-b border-[#E5E5E5]">
        <div className="flex justify-between items-center">
          <CardTitle>Response</CardTitle>
          {status && (
            <Badge className={`${getStatusColor(status)}`}>
              {status} {status >= 200 && status < 300 ? "OK" : "Error"}
            </Badge>
          )}
        </div>
      </CardHeader>
      <CardContent className="p-4">
        {isLoading ? (
          <div className="flex justify-center items-center h-64">
            <div className="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-primary"></div>
          </div>
        ) : response ? (
          <CodeBlock 
            code={JSON.stringify(response, null, 2)} 
            language="json" 
          />
        ) : error ? (
          <div className="bg-red-50 p-4 rounded-md border border-red-200">
            <h3 className="text-red-800 font-medium flex items-center gap-2 mb-2">
              <InfoIcon className="h-5 w-5" />
              Error
            </h3>
            <p className="text-red-700">{error.message}</p>
          </div>
        ) : (
          <div className="bg-[#F7F7F8]/50 rounded-lg p-3 flex items-center text-[#6E6E80] mb-4 h-64 justify-center">
            <InfoIcon className="h-5 w-5 mr-2" />
            <span>Send a request to see the response</span>
          </div>
        )}
      </CardContent>
    </Card>
  );
};

export default ResponseView;
